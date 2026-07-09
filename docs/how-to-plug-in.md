# How to plug this into a new machine

This is the practical, step-by-step version of the "widget" concept from
the main README (section 4). Follow this whether you're setting this up
on your own next machine, or on a client's machine for the first time.

## Before you start

You need:
- A Windows machine, with PowerShell already on it (every Windows machine has this)
- Administrator rights on that machine - DSC needs to install software, register scheduled tasks, and set machine-wide environment variables
- About 10 minutes

## Step 1 - Copy the framework onto the machine

Copy or clone this entire repository onto the target machine. Nothing
needs to be installed first - `ControlPlane.ps1` and
`ControlPlane.Helpers.psm1` only depend on what's already built into
Windows.

## Step 2 - Edit the answer sheet

Open `windows/ControlPlane.config.psd1` and change the values to match
this specific machine or project. You do not need to touch any other
file. A real example:

```powershell
@{
    AllNodes = @(
        @{
            NodeName         = 'localhost'
            ProjectName      = 'NeighbourEcommerce'
            ProjectPath      = 'C:\Projects\NeighbourEcommerce'
            PythonVersion    = '3.11'
            VenvName         = '.venv'
            RequirementsFile = 'requirements.txt'
            ScheduledJobs    = @( @{ Name = 'DailySync'; Script = 'scripts\sync.bat'; Time = '02:00' } )
            SSLCertPath      = 'certs'
            EnvVars          = @{ APP_ENV = 'production' }
        }
    )
}
```

## Step 3 - Make sure WinRM is turned on

DSC needs WinRM (Windows Remote Management) enabled, even to manage the
same machine it's running on - this is a genuine one-time Windows
requirement, not something specific to this project. Most personal
machines don't have it on by default. As Administrator:

```powershell
winrm quickconfig
```

If it asks about a firewall exception failing because the network is set
to "Public," that's fine for local-only use - see section 11 of the main
README for the full story of why, and how to confirm it's not actually a
problem for you.

## Step 4 - Run the tests first (optional, but recommended)

This confirms the checklist itself is healthy before you let it touch a
real machine:

```powershell
cd windows
Import-Module Pester -MinimumVersion 5.0 -Force
Invoke-Pester -Path .\ControlPlane.Tests.ps1 -Output Detailed
```

You should see 15 passed, 0 failed.

## Step 5 - Apply it for real

As Administrator:

```powershell
.\Apply-ControlPlane.ps1
```

Watch the colored progress output. It checks prerequisites, compiles the
checklist and your answer sheet into a MOF file, then applies it - fixing
anything that isn't already correct.

## Step 6 - Verify independently

Don't just trust the log. Check for real, in a separate command, the same
way we did throughout this whole project:

```powershell
Test-Path <your ProjectPath>
Test-Path "<your ProjectPath>\.venv"
```

## If you're doing this for a client

The flow is identical - the only thing that changes is who is physically
present. Show up (or connect remotely), copy the framework onto their
machine, edit `ControlPlane.config.psd1` with their project's real
values, and run `Apply-ControlPlane.ps1`. They never need to understand
DSC, PowerShell, or anything happening under the hood - the machine is
simply correctly configured when you're done.

## If something goes wrong

Section 11 of the main README documents every real problem encountered
while building and testing this framework, with the exact error messages
and the exact fixes - including the WinRM issue above, a PowerShell
command syntax mistake, and a GitHub push permission issue. If you hit an
error, check there first; there's a good chance it's already documented.
