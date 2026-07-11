# ControlPlane.config.psd1
#
# This is the "answer sheet" for ControlPlane.ps1 - it fills in every
# $Node.SomethingHere placeholder in the checklist with a real value.
#
# Edit THIS file to point the framework at a different project. Never
# edit ControlPlane.ps1 itself just to change a folder path or a value.
#
# SECURITY: never put secrets (passwords, API keys, tokens) in this file.
# It is plain, unencrypted text and is meant to be committed to source
# control alongside the project.

@{
    AllNodes = @(
        @{
            NodeName         = 'localhost'
            ProjectName      = 'MyProject'
            ProjectPath      = 'C:\Projects\MyProject'
            PythonVersion    = '3.11'
            VenvName         = '.venv'
            RequirementsFile = 'requirements.txt'

            ScheduledJobs = @(
                @{
                    Name   = 'DailyMaintenance'
                    Script = 'scripts\daily.bat'
                    Time   = '06:30'
                }
            )

            SSLCertPath = 'certs'

            EnvVars = @{
                APP_ENV = 'production'
            }

            # A nightly Scheduled Task that checks this machine for drift
            # (does it still match this configuration?) and writes a plain
            # text report - nobody has to check by hand. It never fixes
            # anything by itself; see windows/Invoke-DriftCheck.ps1.
            DriftCheck = @{
                TaskName   = 'ControlPlane-DriftCheck'
                Time       = '02:00'
                ReportPath = 'C:\Projects\MyProject\drift-report.txt'
            }
        }
    )
}
