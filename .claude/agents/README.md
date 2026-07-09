# The Skills Library

This folder is Layer 2 of the framework - "operations." Layer 1
(`windows/ControlPlane.ps1`) keeps a machine correctly configured. This
layer helps diagnose and fix problems in whatever's *running* on top of
that machine, using Claude Code.

## The 4 skills

| File | What it does |
|---|---|
| [`01-incident-diagnosis.md`](01-incident-diagnosis.md) | Investigates an alert/error and reports a root cause. Read-only. |
| [`02-remediation-pr.md`](02-remediation-pr.md) | Turns a diagnosis into a real PR with a fix, a test, and a rollback plan. |
| [`03-cost-drift-analysis.md`](03-cost-drift-analysis.md) | Flags cloud spend that's drifted from baseline. Report only. |
| [`04-pipeline-health.md`](04-pipeline-health.md) | Diagnoses a failed CI/CD run, hands off to remediation if fixable. |

## Who can use this, and how

**Anyone who clones this repo gets this folder automatically** - Denis,
a freelance developer, or a client's own team. To use a skill, open the
repo in Claude Code and ask it to use the relevant skill against a real
alert, error, or failed pipeline run. No special setup beyond having
Claude Code itself.

This means teammates and freelancers can independently:
- Diagnose a problem (`incident-diagnosis`)
- Draft a fix as a PR (`remediation-pr`)
- Check whether cloud costs look wrong (`cost-drift-analysis`)
- Figure out why a pipeline is red (`pipeline-health`)

## Verifying a suggested fix before it reaches Denis

Every skill's output is deliberately built to be checked, not trusted
blindly:
- `incident-diagnosis` always includes its evidence (logs, metrics) and
  an honest confidence level - not just a conclusion
- `remediation-pr` always runs the real test suite before opening a PR,
  and the PR itself documents how it was verified
- Anyone on the team can re-run those same tests, re-read the same
  evidence, and confirm the reasoning independently - before Denis even
  looks at it

## The approval gate

**Every PR from these skills requires Denis's manual approval before
merging - with exactly one narrow exception.** See
[`approved-fixes/README.md`](approved-fixes/README.md): a small library
of problem-and-solution pairs Denis has personally approved more than
once, and deliberately promoted to auto-merge-with-alert. That library
only ever grows by Denis's own hand - no skill can add to it. Everything
else, regardless of who ran the skill or how confident it is, waits for
Denis's review.
