<#
.SYNOPSIS
    Pester tests for the ControlPlane DSC checklist.

.DESCRIPTION
    Two kinds of tests live here:
      1. Unit tests against ControlPlane.Helpers.psm1 - the actual
         "is this correct?" logic, tested directly with mocks, no DSC
         or real machine changes involved.
      2. A compile check against ControlPlane.ps1 itself - confirms the
         checklist + the sample answer sheet still compile into a MOF
         file containing every expected checklist item.

.NOTES
    Run with: Invoke-Pester -Path .\ControlPlane.Tests.ps1 -Output Detailed
#>

BeforeAll {
    $script:HelpersModule = Join-Path $PSScriptRoot 'ControlPlane.Helpers.psm1'
    Import-Module $script:HelpersModule -Force
}

Describe 'Test-GitAvailable' {
    Context 'when Git is installed' {
        It 'returns $true' {
            Mock -ModuleName ControlPlane.Helpers Get-Command {
                [pscustomobject]@{ Name = 'git' }
            } -ParameterFilter { $Name -eq 'git' }

            Test-GitAvailable | Should -BeTrue
        }
    }

    Context 'when Git is not installed' {
        It 'returns $false' {
            Mock -ModuleName ControlPlane.Helpers Get-Command {
                $null
            } -ParameterFilter { $Name -eq 'git' }

            Test-GitAvailable | Should -BeFalse
        }
    }
}

Describe 'Test-PythonVersionOk' {
    Context 'when Python is not installed' {
        It 'returns $false' {
            Mock -ModuleName ControlPlane.Helpers Get-Command {
                $null
            } -ParameterFilter { $Name -eq 'python' }

            Test-PythonVersionOk -RequiredVersion '3.11' | Should -BeFalse
        }
    }

    Context 'when the installed version is older than required' {
        It 'returns $false' {
            Mock -ModuleName ControlPlane.Helpers Get-Command {
                [pscustomobject]@{ Name = 'python' }
            } -ParameterFilter { $Name -eq 'python' }
            Mock -ModuleName ControlPlane.Helpers python { 'Python 3.9.0' }

            Test-PythonVersionOk -RequiredVersion '3.11' | Should -BeFalse
        }
    }

    Context 'when the installed version meets the requirement' {
        It 'returns $true' {
            Mock -ModuleName ControlPlane.Helpers Get-Command {
                [pscustomobject]@{ Name = 'python' }
            } -ParameterFilter { $Name -eq 'python' }
            Mock -ModuleName ControlPlane.Helpers python { 'Python 3.12.1' }

            Test-PythonVersionOk -RequiredVersion '3.11' | Should -BeTrue
        }
    }
}

Describe 'Test-VirtualEnvPresent' {
    Context 'when the .venv folder exists' {
        It 'returns $true' {
            Mock -ModuleName ControlPlane.Helpers Test-Path { $true }

            Test-VirtualEnvPresent -ProjectPath 'C:\Projects\Demo' -VenvName '.venv' | Should -BeTrue
        }
    }

    Context 'when the .venv folder is missing' {
        It 'returns $false' {
            Mock -ModuleName ControlPlane.Helpers Test-Path { $false }

            Test-VirtualEnvPresent -ProjectPath 'C:\Projects\Demo' -VenvName '.venv' | Should -BeFalse
        }
    }
}

Describe 'Test-RequiredPipPackagesInstalled' {
    Context 'when requirements.txt does not exist' {
        It 'returns $true (nothing required, so nothing missing)' {
            Mock -ModuleName ControlPlane.Helpers Test-Path { $false } -ParameterFilter { $Path -like '*requirements.txt' }

            Test-RequiredPipPackagesInstalled -ProjectPath 'C:\Projects\Demo' -VenvName '.venv' -RequirementsFile 'requirements.txt' |
                Should -BeTrue
        }
    }

    Context 'when requirements.txt exists but the venv pip.exe does not' {
        It 'returns $false (not ready to check yet)' {
            Mock -ModuleName ControlPlane.Helpers Test-Path { $true }  -ParameterFilter { $Path -like '*requirements.txt' }
            Mock -ModuleName ControlPlane.Helpers Test-Path { $false } -ParameterFilter { $Path -like '*pip.exe' }

            Test-RequiredPipPackagesInstalled -ProjectPath 'C:\Projects\Demo' -VenvName '.venv' -RequirementsFile 'requirements.txt' |
                Should -BeFalse
        }
    }
}

Describe 'Test-ScheduledJobRegistered' {
    Context 'when the task is already registered' {
        It 'returns $true' {
            Mock -ModuleName ControlPlane.Helpers Get-ScheduledTask { [pscustomobject]@{ TaskName = 'DailyMaintenance' } }

            Test-ScheduledJobRegistered -TaskName 'DailyMaintenance' | Should -BeTrue
        }
    }

    Context 'when the task does not exist yet' {
        It 'returns $false' {
            Mock -ModuleName ControlPlane.Helpers Get-ScheduledTask { $null }

            Test-ScheduledJobRegistered -TaskName 'DailyMaintenance' | Should -BeFalse
        }
    }
}

Describe 'Test-SslCertificatePresent' {
    Context 'when the certificate folder exists' {
        It 'returns $true' {
            Mock -ModuleName ControlPlane.Helpers Test-Path { $true }

            Test-SslCertificatePresent -ProjectPath 'C:\Projects\Demo' -SSLCertPath 'certs' | Should -BeTrue
        }
    }

    Context 'when the certificate folder is missing' {
        It 'returns $false (caller decides whether to warn - this function never auto-creates certs)' {
            Mock -ModuleName ControlPlane.Helpers Test-Path { $false }

            Test-SslCertificatePresent -ProjectPath 'C:\Projects\Demo' -SSLCertPath 'certs' | Should -BeFalse
        }
    }
}

Describe 'ControlPlane.ps1 compiles into a valid MOF' {
    BeforeAll {
        $script:MofOutputPath = Join-Path $TestDrive 'MOF'
        . (Join-Path $PSScriptRoot 'ControlPlane.ps1')
        $configData = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'ControlPlane.config.psd1')
        ControlPlane -ConfigurationData $configData -OutputPath $script:MofOutputPath | Out-Null
        $script:MofContent = Get-Content (Join-Path $script:MofOutputPath 'localhost.mof') -Raw
    }

    It 'produces a localhost.mof file' {
        Join-Path $script:MofOutputPath 'localhost.mof' | Should -Exist
    }

    It 'contains all 9 expected checklist items' {
        $expectedItems = @(
            'ProjectDirectory',
            'GitInstalled',
            'PythonInstalled',
            'VirtualEnvironment',
            'PipPackagesInstalled',
            'ScheduledJob_DailyMaintenance',
            'SslCertificatePresence',
            'EnvVar_APP_ENV',
            'DriftCheckScheduledTask'
        )

        foreach ($item in $expectedItems) {
            $script:MofContent | Should -Match ([regex]::Escape($item))
        }
    }
}
