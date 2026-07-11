<#
.SYNOPSIS
    Checks this machine for configuration drift and writes a plain-text report.

.DESCRIPTION
    This is the script a nightly Scheduled Task runs on its own, with nobody
    watching it. It asks the DSC Local Configuration Manager (LCM) - the
    Windows service that already knows the last configuration this machine
    was told to have - one simple question: "does this machine still match
    that configuration, right now?" Then it writes the answer to a plain
    text file so a human can read it in the morning instead of checking by
    hand.

    This script only checks. It never fixes anything. Fixing drift is a
    separate, human-approved step (re-running Apply-ControlPlane.ps1, which
    calls Start-DscConfiguration) - the same "a human approves before
    anything unattended actually changes the machine" rule used everywhere
    else in this project (see .claude/agents/README.md).

.PARAMETER ReportPath
    Where to write the plain-text report. The file is overwritten every
    time this runs, so it always shows the most recent check, not a
    history of every past run.

.NOTES
    Author: Denis Muriuki

    Where this idea came from: during a real interview, a Concentrix
    PowerShell engineer (Andrea) described exactly this pattern already
    running in production there - a Task Scheduler job that checks a whole
    fleet of machines overnight (because checking many machines can take a
    few hours) and produces a report, so a human reads the outcome instead
    of checking each machine by hand. This script is that same idea,
    scaled down to one machine. See README section 12 for the full story.

    This has been written and reviewed but not yet run for real against a
    live Scheduled Task - see docs/how-to-plug-in.md for how to try it.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'

$checkTime = Get-Date
$result    = Test-DscConfiguration -Detailed

$lines = @(
    'ControlPlane drift check'
    "Run at:            $checkTime"
    "In desired state:  $($result.InDesiredState)"
    ''
)

if ($result.ResourcesNotInDesiredState) {
    $lines += 'Resources that have drifted (do not match the last applied configuration):'
    foreach ($resource in $result.ResourcesNotInDesiredState) {
        $lines += " - $($resource.ResourceId)"
    }
    $lines += ''
    $lines += 'To fix: re-run Apply-ControlPlane.ps1 as Administrator. This report never fixes anything by itself.'
} else {
    $lines += 'No drift detected. Every checklist item still matches the last applied configuration.'
}

# Make sure the folder the report lives in actually exists before writing to it.
$reportFolder = Split-Path -Path $ReportPath -Parent
if ($reportFolder -and -not (Test-Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder -Force | Out-Null
}

$lines | Out-File -FilePath $ReportPath -Encoding utf8 -Force
