<#
.SYNOPSIS
    Enforces the desired state of a Windows DevOps control plane machine.

.DESCRIPTION
    ControlPlane is a PowerShell DSC configuration that ensures a Windows
    machine has the tools, environment, and scheduled jobs a DevOps project
    needs: Git, Python + virtual environment, pip packages, Task Scheduler
    jobs, SSL certificates, and environment variables.

    It is idempotent: running it repeatedly only changes what is not yet
    in the desired state.

.NOTES
    Author:  Denis Muriuki
    Module:  PSDesiredStateConfiguration (built into Windows, no install needed)
#>

Configuration ControlPlane
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    # Where the testable "is this correct?" logic lives - see
    # ControlPlane.Helpers.psm1. Every Script resource below borrows this
    # path via $using:HelpersModulePath to load that toolbox before using it.
    $HelpersModulePath = Join-Path $PSScriptRoot 'ControlPlane.Helpers.psm1'

    Node $AllNodes.NodeName
    {
        # --- Checklist item 1: the project folder must exist ---
        File ProjectDirectory
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = $Node.ProjectPath
        }

        # --- Checklist item 2: Git must be installed and on PATH ---
        Script GitInstalled
        {
            GetScript = {
                Import-Module $using:HelpersModulePath -Force
                return @{ Result = Test-GitAvailable }
            }
            TestScript = {
                Import-Module $using:HelpersModulePath -Force
                return Test-GitAvailable
            }
            SetScript = {
                winget install --id Git.Git -e --source winget `
                    --accept-package-agreements --accept-source-agreements
            }
        }

        # --- Checklist item 3: Python 3.11+ must be installed ---
        Script PythonInstalled
        {
            GetScript = {
                $py = Get-Command python -ErrorAction SilentlyContinue
                return @{ Result = if ($py) { (& python --version) } else { 'not found' } }
            }
            TestScript = {
                Import-Module $using:HelpersModulePath -Force
                return Test-PythonVersionOk -RequiredVersion $using:Node.PythonVersion
            }
            SetScript = {
                winget install --id Python.Python.3.11 -e --source winget `
                    --accept-package-agreements --accept-source-agreements
            }
            DependsOn = '[Script]GitInstalled'
        }

        # --- Checklist item 4: a Python virtual environment must exist ---
        Script VirtualEnvironment
        {
            GetScript = {
                Import-Module $using:HelpersModulePath -Force
                return @{ Result = Test-VirtualEnvPresent -ProjectPath $using:Node.ProjectPath -VenvName $using:Node.VenvName }
            }
            TestScript = {
                Import-Module $using:HelpersModulePath -Force
                return Test-VirtualEnvPresent -ProjectPath $using:Node.ProjectPath -VenvName $using:Node.VenvName
            }
            SetScript = {
                $venvPath = Join-Path $using:Node.ProjectPath $using:Node.VenvName
                & python -m venv $venvPath
            }
            DependsOn = '[Script]PythonInstalled'
        }

        # --- Checklist item 5: all pip packages from requirements.txt must be installed ---
        Script PipPackagesInstalled
        {
            GetScript = {
                return @{ Result = 'see TestScript' }
            }
            TestScript = {
                Import-Module $using:HelpersModulePath -Force
                return Test-RequiredPipPackagesInstalled `
                    -ProjectPath      $using:Node.ProjectPath `
                    -VenvName         $using:Node.VenvName `
                    -RequirementsFile $using:Node.RequirementsFile
            }
            SetScript = {
                $venvPip = Join-Path $using:Node.ProjectPath "$($using:Node.VenvName)\Scripts\pip.exe"
                $reqFile = Join-Path $using:Node.ProjectPath $using:Node.RequirementsFile
                & $venvPip install -r $reqFile
            }
            DependsOn = '[Script]VirtualEnvironment'
        }

        # --- Checklist item 6: each scheduled job must be registered in Task Scheduler ---
        foreach ($job in $Node.ScheduledJobs)
        {
            Script "ScheduledJob_$($job.Name)"
            {
                GetScript = {
                    Import-Module $using:HelpersModulePath -Force
                    return @{ Result = Test-ScheduledJobRegistered -TaskName $using:job.Name }
                }
                TestScript = {
                    Import-Module $using:HelpersModulePath -Force
                    return Test-ScheduledJobRegistered -TaskName $using:job.Name
                }
                SetScript = {
                    $action  = New-ScheduledTaskAction -Execute $using:job.Script
                    $trigger = New-ScheduledTaskTrigger -Daily -At $using:job.Time
                    Register-ScheduledTask -TaskName $using:job.Name -Action $action -Trigger $trigger -Force
                }
                DependsOn = '[File]ProjectDirectory'
            }
        }

        # --- Checklist item 7: warn (do not auto-fix) if SSL certs are missing ---
        Script SslCertificatePresence
        {
            GetScript = {
                Import-Module $using:HelpersModulePath -Force
                return @{ Result = Test-SslCertificatePresent -ProjectPath $using:Node.ProjectPath -SSLCertPath $using:Node.SSLCertPath }
            }
            TestScript = {
                Import-Module $using:HelpersModulePath -Force
                $certsPresent = Test-SslCertificatePresent -ProjectPath $using:Node.ProjectPath -SSLCertPath $using:Node.SSLCertPath
                if (-not $certsPresent) {
                    $certPath = Join-Path $using:Node.ProjectPath $using:Node.SSLCertPath
                    Write-Warning "SSL certificate folder not found at '$certPath'. This framework never auto-generates certificates - add them manually."
                }
                return $true
            }
            SetScript = {
                # Intentionally empty. TestScript always returns $true above,
                # so SetScript never runs. Certificates are security-sensitive
                # and must be provisioned by a human, never auto-created here.
            }
        }

        # --- Checklist item 8: required environment variables must be set ---
        foreach ($varName in $Node.EnvVars.Keys)
        {
            Environment "EnvVar_$varName"
            {
                Ensure = 'Present'
                Name   = $varName
                Value  = $Node.EnvVars[$varName]
            }
        }
    }
}
