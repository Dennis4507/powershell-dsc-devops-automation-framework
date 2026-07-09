<#
.SYNOPSIS
    Azure AD / Microsoft 365 identity configuration for this framework.

.DESCRIPTION
    Extends the exact same pattern as windows/ControlPlane.ps1 - "write
    down what should be true, let DSC enforce it" - to a Microsoft 365 /
    Azure AD tenant instead of a Windows machine. Uses Microsoft365DSC
    (the community-maintained module: github.com/microsoft/Microsoft365DSC)
    to declare the app registration and service principal this framework
    needs in order to operate against a client's tenant.

    This is Layer 3 (Deployment) territory - one level above the Windows
    machine itself, closer to "who is this framework allowed to act as."

.NOTES
    Requires: Install-Module Microsoft365DSC
    Status: skeleton, written to show the intended shape - NOT yet run
    against a real tenant. See docs/m365-dsc-production-notes.md for
    exactly what's needed before this goes anywhere near production.
#>

Configuration M365ControlPlaneIdentity
{
    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node $AllNodes.NodeName
    {
        # --- Checklist item 1: the automation app registration must exist ---
        AADApplication ControlPlaneApp
        {
            DisplayName = $Node.AppDisplayName
            Ensure      = 'Present'
            Credential  = $Credential
        }

        # --- Checklist item 2: its service principal must exist - this is
        #     what actually authenticates when the framework runs ---
        AADServicePrincipal ControlPlaneServicePrincipal
        {
            AppId      = $Node.AppDisplayName
            Ensure     = 'Present'
            Credential = $Credential
            DependsOn  = '[AADApplication]ControlPlaneApp'
        }
    }
}
