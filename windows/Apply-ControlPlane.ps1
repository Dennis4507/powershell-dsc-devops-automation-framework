<#
.SYNOPSIS
    One-command wrapper: compiles ControlPlane.ps1 + the config data file,
    then enforces desired state on this machine.

.DESCRIPTION
    Run this file to apply the DSC checklist end to end. It:
      1. Checks prerequisites (Administrator rights, config file present)
      2. Loads the checklist (ControlPlane.ps1)
      3. Compiles the checklist + answer sheet into a MOF file
      4. Tells the LCM to check the machine against it and fix anything wrong
      5. Prints a final status report

.NOTES
    Author: Denis Muriuki
    Must be run as Administrator - DSC needs to install software, create
    scheduled tasks, and set machine-wide environment variables.
#>

[CmdletBinding()]
param(
    [string]$ConfigDataPath = (Join-Path $PSScriptRoot 'ControlPlane.config.psd1'),
    [string]$OutputPath     = (Join-Path $PSScriptRoot 'MOF')
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

# --- Step 1: prerequisite checks ---
Write-Step "Checking prerequisites"

$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin     = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Right-click PowerShell and choose 'Run as Administrator', then try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "Running as Administrator - OK" -ForegroundColor Green

if (-not (Test-Path $ConfigDataPath)) {
    Write-Host "Config file not found: $ConfigDataPath" -ForegroundColor Red
    exit 1
}
Write-Host "Config file found: $ConfigDataPath" -ForegroundColor Green

# --- Step 2: load the checklist ---
Write-Step "Loading ControlPlane checklist"
try {
    . (Join-Path $PSScriptRoot 'ControlPlane.ps1')
    Write-Host "Checklist loaded - OK" -ForegroundColor Green
} catch {
    Write-Host "Failed to load ControlPlane.ps1: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --- Step 3: compile the checklist + answer sheet into a MOF file ---
Write-Step "Compiling configuration (checklist + answer sheet -> MOF)"
try {
    ControlPlane -ConfigurationData $ConfigDataPath -OutputPath $OutputPath | Out-Null
    Write-Host "Compiled successfully to: $OutputPath" -ForegroundColor Green
} catch {
    Write-Host "Failed to compile configuration: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --- Step 4: apply it - check the machine and fix anything wrong ---
Write-Step "Applying configuration (checking machine, fixing anything wrong)"
try {
    Start-DscConfiguration -Path $OutputPath -Wait -Verbose -Force -ErrorAction Stop
    Write-Host "`nControlPlane applied successfully." -ForegroundColor Green
} catch {
    Write-Host "`nApplying configuration failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# --- Step 5: report current status ---
Write-Step "Current status"
Get-DscConfigurationStatus | Format-List StartDate, Status, Type, Mode
