# ControlPlane.config.test.psd1
#
# A throwaway SANDBOX answer sheet - only for testing Apply-ControlPlane.ps1
# for real, without touching anything meaningful on the machine.
#
# - ProjectPath points at a clearly-named test folder under C:\Temp
# - ScheduledJobs is empty - no real Scheduled Task gets created
# - EnvVars uses an obviously-fake name, not something like APP_ENV
#
# Safe to delete this file (and everything it creates) once testing is done.

@{
    AllNodes = @(
        @{
            NodeName         = 'localhost'
            ProjectName      = 'DscSandboxTest'
            ProjectPath      = 'C:\Temp\DSC-ControlPlane-Test'
            PythonVersion    = '3.8'
            VenvName         = '.venv'
            RequirementsFile = 'requirements.txt'
            ScheduledJobs    = @()
            SSLCertPath      = 'certs'
            EnvVars          = @{ DSC_SANDBOX_TEST = 'hello-from-dsc-framework' }
            DriftCheck       = @{
                TaskName   = 'ControlPlane-DriftCheck-Sandbox'
                Time       = '02:00'
                ReportPath = 'C:\Temp\DSC-ControlPlane-Test\drift-report.txt'
            }
        }
    )
}
