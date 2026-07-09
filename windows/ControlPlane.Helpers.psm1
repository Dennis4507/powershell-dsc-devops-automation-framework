<#
.SYNOPSIS
    The testable "is this correct?" logic behind ControlPlane.ps1's checklist.

.DESCRIPTION
    Every function here answers exactly one yes/no question about the
    machine's current state - the same checks that used to live directly
    inside each Script resource's TestScript in ControlPlane.ps1.

    Moving this logic here means:
      1. ControlPlane.ps1's Script resources stay short - each TestScript
         just calls one of these functions instead of repeating the logic.
      2. ControlPlane.Tests.ps1 (Pester) can call these functions directly
         and mock things like Get-Command, without ever needing DSC to
         run first.

.NOTES
    This file is deployed alongside ControlPlane.ps1. Each checklist item
    that needs it imports it using a path worked out once, at the top of
    ControlPlane.ps1, so it works both here (this machine) and later on
    a real target machine once the whole windows/ folder is copied over.
#>

function Test-GitAvailable {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    return [bool](Get-Command git -ErrorAction SilentlyContinue)
}

function Test-PythonVersionOk {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$RequiredVersion
    )

    $py = Get-Command python -ErrorAction SilentlyContinue
    if (-not $py) { return $false }

    $versionText = (& python --version) -replace 'Python\s+', ''
    $installed   = [version]$versionText
    $required    = [version]$RequiredVersion

    return ($installed -ge $required)
}

function Test-VirtualEnvPresent {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [string]$ProjectPath,
        [Parameter(Mandatory)] [string]$VenvName
    )

    $venvPath = Join-Path $ProjectPath $VenvName
    return Test-Path $venvPath
}

function Test-RequiredPipPackagesInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [string]$ProjectPath,
        [Parameter(Mandatory)] [string]$VenvName,
        [Parameter(Mandatory)] [string]$RequirementsFile
    )

    $venvPip = Join-Path $ProjectPath "$VenvName\Scripts\pip.exe"
    $reqFile = Join-Path $ProjectPath $RequirementsFile

    if (-not (Test-Path $reqFile)) { return $true }
    if (-not (Test-Path $venvPip)) { return $false }

    $installedPackages = & $venvPip freeze
    $requiredPackages  = Get-Content $reqFile | Where-Object { $_.Trim() -ne '' }

    foreach ($package in $requiredPackages) {
        $packageName      = ($package -split '==')[0].Trim()
        $alreadyInstalled = $installedPackages | Where-Object { $_ -like "$packageName*" }
        if (-not $alreadyInstalled) {
            return $false
        }
    }

    return $true
}

function Test-ScheduledJobRegistered {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [string]$TaskName
    )

    return [bool](Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)
}

function Test-SslCertificatePresent {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [string]$ProjectPath,
        [Parameter(Mandatory)] [string]$SSLCertPath
    )

    $certPath = Join-Path $ProjectPath $SSLCertPath
    return Test-Path $certPath
}
