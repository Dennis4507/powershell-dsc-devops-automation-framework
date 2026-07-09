# Approved Fix: Celery worker OOM restart (HeRiko eBay Platform)

## Status: Approved

## Problem signature (all must match)
- Service: Celery worker, HeRiko eBay Platform (Hetzner K3s)
- Symptom: Sentry/Prometheus shows the worker killed by an out-of-memory
  signal, with no application-code exception involved
- Root cause: a transient memory spike from a large batch job, not a
  leak - confirmed by Grafana showing memory returning to normal
  baseline shortly before the spike, not climbing steadily beforehand

## Approved solution
Restart the affected Celery worker pod only - no code change. Scoped
strictly to the single affected deployment, nothing cluster-wide.

## Boundaries (falls back to manual review if any of these are true)
- The same worker has OOM-killed 3 or more times within the same 24-hour
  window (that pattern means a leak, not a spike - needs real
  investigation, not another restart)
- Memory does not return to baseline after the restart
- Any other service is affected at the same time (signals something
  bigger than one worker's memory spike)

## Reference PRs
- (add links here once this pattern has been manually approved at least
  twice)
