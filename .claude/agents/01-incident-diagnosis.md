---
name: incident-diagnosis
description: Diagnose a production alert or error before proposing any fix. Read-only - never makes changes.
---

# Skill: Incident Diagnosis

## Purpose
When a production alert fires, figure out the real root cause before anyone
proposes a fix. This skill only investigates and reports - it never changes
anything.

## Trigger conditions
Invoke this skill when:
- A Prometheus/Alertmanager alert fires for any HeRiko eBay Platform service
  (FastAPI, Celery, CLIP/FAISS, PostgreSQL, Grafana, Loki)
- Sentry reports a new or spiking error group
- A scheduled job (Task Scheduler / cron) fails silently
- Denis pastes an error message or log excerpt and asks "what's wrong?"

## What to read (in this order)
1. The alert/error payload itself - service, severity, message, timestamp
2. The Sentry issue detail - stack trace, breadcrumbs, affected release/commit
3. Grafana dashboards for the affected service, around the alert time
   (CPU / memory / latency)
4. Loki logs for the affected pod/service, filtered to +/- 10 minutes around
   the alert
5. Recent GitHub Actions deploy history (`deploy-all.yml` runs) - did a
   deploy happen right before this started?
6. Any prior incidents in the knowledge base matching this pattern

## How to diagnose
1. Establish the timeline - when did it start, is it still happening, is it
   getting worse?
2. Correlate with recent changes - deploys, config changes, or (for
   control-plane issues) DSC drift, checked via `Test-DscConfiguration`
3. Classify the failure: application bug, infrastructure drift, resource
   exhaustion, external dependency, or configuration error
4. Identify the actual root cause, not just the symptom (e.g. "Celery worker
   OOM-killed," not "the task didn't finish")

## What to output
```
Service affected:
Severity:
Root cause (best hypothesis):
Evidence: (logs/metrics that support the hypothesis)
Confidence: High / Medium / Low
Recommended next step: hand off to 02-remediation-pr.md, or flag for
manual investigation if no safe automated fix exists
```

## Guardrails
- Never restart, redeploy, or modify anything during diagnosis - read-only,
  always.
- If investigating requires credentials/secrets, stop and ask Denis rather
  than guessing or trying to work around it.
- If the same root cause has fired 3+ times in 24 hours, flag it explicitly
  as recurring - it needs a permanent fix, not another one-off patch.
