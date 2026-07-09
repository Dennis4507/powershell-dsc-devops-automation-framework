---
name: cost-drift-analysis
description: Catch cloud spend that has drifted away from baseline before it becomes a surprise bill. Read-only - never changes infrastructure.
---

# Skill: Cost Drift Analysis

## Purpose
Catch cloud spend that's silently drifted away from baseline before it
becomes a surprise bill. Produces a report only - never changes
infrastructure.

## Trigger conditions
- Scheduled: run weekly (or monthly) against each cloud account in use
- On demand: Denis asks "did our cloud costs change?"

## What to read
1. Current billing period spend, broken down by service, for each provider
   in use:
   - Hetzner (HeRiko eBay Platform - K3s cluster)
   - AWS Cost Explorer (WooCommerce, 50,000 products)
   - Azure Cost Management (backup VM, and any client VMs)
2. The previous 3 months of the same data, as a baseline
3. Recent infrastructure changes (new resources provisioned via Terraform,
   VM size changes, newly deployed services)

## How to analyse
1. Compare current spend per-service against the trailing 3-month average
2. Flag any service that's grown more than 20% month-over-month, or any
   brand-new cost line that wasn't there before
3. Cross-reference spikes against recent deploys/infra changes - a spike
   right after a deploy is more explainable (and more urgent to confirm)
   than a slow, unexplained creep
4. Check for obviously wasteful patterns: idle-but-still-billed VMs,
   oversized instances for actual load, orphaned storage/snapshots,
   unattached IPs

## What to output
```
Total spend this period vs. baseline: (with % change)
Anomalies found: (service, amount, % change, likely cause if known)
Optimisation suggestions: ranked by estimated savings, each with the
  specific action - e.g. "downsize VM X from B2s to B1s, saves ~EUR X/month,
  safe because CPU utilisation has been under 15% for 30 days"
Nothing found: if spend is within normal range, say so explicitly -
  never manufacture findings just to have something to report
```

## Guardrails
- Never resize, stop, or delete any resource automatically - this skill
  only reports and recommends.
- Flag (never act on) anything touching a client's billing account
  separately from Denis's own - client cost changes need direct client
  communication, not silent optimisation.
