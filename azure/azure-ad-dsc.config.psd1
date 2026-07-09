# azure-ad-dsc.config.psd1
#
# The answer sheet for azure-ad-dsc.ps1 - same idea as
# windows/ControlPlane.config.psd1, just describing a Microsoft 365 /
# Azure AD tenant instead of a Windows machine.
#
# SECURITY: never put real secrets, client secrets, or certificate
# private keys in this file. Authentication should come from a
# certificate + Key Vault, not anything written here - see
# docs/m365-dsc-production-notes.md.

@{
    AllNodes = @(
        @{
            NodeName       = 'localhost'
            AppDisplayName = 'ControlPlane Automation'
            TenantId       = '<client-tenant-id-goes-here>'
        }
    )
}
