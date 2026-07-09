# Approved Fix: DSC control-plane drift - safe re-apply

## Status: Approved

## Problem signature (all must match)
- Service: this DSC control plane (the `ControlPlane.ps1` checklist)
- Symptom: `Test-DscConfiguration` reports one or more of `GitInstalled`,
  `PythonInstalled`, `VirtualEnvironment`, `PipPackagesInstalled`,
  `ScheduledJob_*`, or `EnvVar_*` as not in the desired state
- Root cause: configuration drift (something changed outside of DSC) -
  not a change to `ControlPlane.ps1` or `ControlPlane.config.psd1`
  themselves

## Approved solution
Re-run `Apply-ControlPlane.ps1` against the existing, unchanged
`ControlPlane.config.psd1`. This only re-applies already-reviewed,
already-tested checklist logic - it introduces no new code.

## Boundaries (falls back to manual review if any of these are true)
- `ControlPlane.ps1`, `ControlPlane.Helpers.psm1`, or
  `ControlPlane.config.psd1` have themselves changed since this pattern
  was last manually approved
- The drift involves the SSL certificate item
  (`SslCertificatePresence`) - certificates are never auto-remediated,
  by design (see section 6 of the main README)
- More than 3 checklist items are out of state at once (likely signals a
  bigger problem than routine drift, worth a real look)

## Reference PRs
- (add links here once this pattern has been manually approved at least
  twice)
