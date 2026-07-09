# Microsoft 365 / Azure AD DSC - path to production

`azure/azure-ad-dsc.ps1` is a skeleton. A skeleton means it shows the
shape of what we want, but it has not actually been run against a real
Microsoft 365 tenant yet. This document explains, step by step, what
needs to happen between "skeleton" and "safe to actually use."

## 0. Where this should actually run

This should not run from a personal computer. It should run from a
dedicated Azure Virtual Machine instead. An Azure Virtual Machine, or
Azure VM, is a computer that lives in Microsoft's cloud rather than on a
desk. There are two good reasons for this choice.

The first reason is storage space. Microsoft365DSC needs a large amount
of disk space, often more than one gigabyte once you count everything it
depends on. A personal laptop may not have that space free. An Azure VM
can be created with as much storage as needed, so this is never a
problem there.

The second reason is security. If this ran from a personal computer,
that computer would end up holding the keys to a client's Microsoft 365
tenant. Keeping that access on a separate, dedicated Azure VM means a
problem on the personal computer never puts a client's tenant at risk.

This connects directly to `azure/main.tf`, which is already planned in
this project. Terraform is a tool that creates cloud infrastructure from
a written description instead of clicking through a website by hand.
`azure/main.tf` was always going to create an Azure VM for the Windows
checklist (`ControlPlane.ps1`) to run on. That same VM is also where this
Microsoft 365 file should run. One VM does both jobs: it keeps itself
correctly set up, and it manages the client's Microsoft 365 tenant.

## 1. Test against a free developer tenant first, never a real one

Microsoft gives out free Microsoft 365 developer tenants specifically
for testing things like this. This configuration should be proven
correct there first. Only once it is confirmed safe should it ever be
pointed at a real client's tenant.

## 2. Replace the placeholder authentication

The skeleton file currently uses a generic placeholder called
`$Credential`. This is a stand-in, not something that actually works yet.
There are two real options for production, and running on an Azure VM
makes the better one available:

- **Managed identity (the better option, and only possible on an Azure
  VM).** Azure can give a VM its own trusted identity automatically,
  with no password and no certificate to manage by hand at all. Azure AD
  already trusts it. This removes an entire category of secrets to
  protect.
- **Certificate-based authentication (the fallback option).** If a
  managed identity cannot be used for some reason, the app registration
  can instead be given a certificate. The certificate's private key must
  live in a proper secret store, never inside a script or a config file.

## 3. Get tenant admin consent

An app registration cannot do anything inside a tenant until a tenant
administrator personally approves the specific permissions it is asking
for. This is a manual, one-time step that a client's own administrator
must perform. It cannot be automated away, because it is a deliberate
security checkpoint, not an oversight.

## 4. Secrets belong in a secret store, never in this repository

The same rule from `ControlPlane.config.psd1` applies here, with higher
stakes. The tenant ID and any client-specific values should come from
Azure Key Vault, a secure storage service built for exactly this purpose,
referenced by name at the moment they are needed. They should never be
written directly into a file that gets saved into source control.

## 5. Verify the actual resource properties before running anything

Microsoft365DSC is a real, actively maintained, open-source module. Its
exact property names change between versions over time. Before this is
ever run for real, the current module's own documentation should be
checked directly, using `Get-DscResource -Module Microsoft365DSC` once it
is installed, rather than trusting this skeleton file's property names as
final.

## 6. Use Microsoft365DSC's own safety tooling

The module comes with its own built-in tools made specifically for
avoiding accidental damage to a real tenant:

- `Export-M365DSCConfiguration` reads a tenant's current, real settings
  and writes out a matching configuration file automatically. This is a
  good way to see the correct shape of a setting before writing it by
  hand.
- The module also supports test-only, read-only modes, the same idea as
  `Test-DscConfiguration` on the Windows side of this project.

## 7. Only then, connect it to CI/CD

Once this has been proven safe against a test tenant, it can follow the
same pattern already used for the Windows checklist: a GitHub Actions
workflow that checks the configuration automatically on every change,
with a human approval step required before anything is ever applied to a
real client's tenant. This matches the human-in-the-loop approval model
already documented in
[`.claude/agents/README.md`](../.claude/agents/README.md).

---

**Summary:** this skeleton proves the same DSC pattern works beyond just
Windows machines. The real path to production is to run it from a
dedicated Azure VM (not a personal computer), test it against a free
developer tenant first, use a managed identity for authentication where
possible, keep all secrets in Azure Key Vault, and confirm everything
against the module's current real documentation before it ever touches a
client's actual tenant.
