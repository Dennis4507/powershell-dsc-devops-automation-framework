---
name: pipeline-health
description: Catch CI/CD pipeline problems and propose a fix via the remediation-pr skill when appropriate.
---

# Skill: Pipeline Health Check

## Purpose
Catch CI/CD pipeline problems (failing builds, flaky tests, stuck deploys)
before they block real work, and hand off to `02-remediation-pr.md` when a
safe automated fix is possible.

## Trigger conditions
- A GitHub Actions workflow run fails (`deploy-all.yml`, `validate-dsc.yml`,
  or any other pipeline in use)
- A pipeline has been stuck / running unusually long
- Denis asks "why is the pipeline red?"

## What to read
1. The failed workflow run's logs, starting from the **first** failing step
   - not just the last one, since later steps often fail only as a
   consequence of an earlier one
2. The diff/commit that triggered this run - what actually changed
3. Whether this is a new failure or a recurring flaky one (check recent run
   history for the same workflow)
4. Any pinned dependency/action versions that might have silently changed
   behaviour (e.g. an action referenced by `@main` instead of a pinned tag)

## How to diagnose
1. Classify the failure: code bug, test flakiness, environment/dependency
   issue, secrets/permissions issue, or a GitHub-side outage
2. For flaky tests: check if the same test has failed intermittently before
   - if so, the flakiness itself is the real problem, not this one run
3. For dependency/environment issues: identify exactly what changed
   (package version, runner image, action version)

## What to output
```
Pipeline: (name, run link)
Failing step:
Root cause:
Is this new or recurring?
Recommended fix: hand off to 02-remediation-pr.md if a code/config change
  will fix it; otherwise recommend the manual action needed
  (e.g. re-run, rotate an expired secret)
```

## Guardrails
- Never disable a failing check just to unblock a merge - fix the real
  problem or flag it for Denis, never hide it.
- Never rotate or view secret values directly - if a secret issue is
  suspected, name which secret and why, and let Denis handle it.
