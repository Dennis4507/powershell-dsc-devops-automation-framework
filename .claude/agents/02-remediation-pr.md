---
name: remediation-pr
description: Turn a completed diagnosis into a proposed fix as a pull request. Never merges or deploys anything itself.
---

# Skill: Remediation PR

## Purpose
Turn a completed diagnosis (from `01-incident-diagnosis.md`) into an actual
proposed fix - as a pull request Denis reviews and approves. This skill
never merges or deploys anything itself; a human is always the last step.

## Trigger conditions
- A diagnosis report exists with **Confidence: High** or **Medium**, and a
  clear, scoped fix is possible
- Denis explicitly asks for a fix PR for a known issue

## Inputs needed
- The diagnosis report (root cause, evidence, affected service)
- Read access to the relevant repo (HeRiko eBay Platform, WooCommerce
  integration, or this DSC framework itself)
- Confirmation of which environment this affects (dev / staging / production)

## Steps
1. **Check for precedent first.** Compare the diagnosis's problem
   signature (service + error pattern + root cause classification) against
   every entry in `.claude/agents/approved-fixes/`. This determines which
   path below applies - see "Approval gate" for exactly what counts as a
   match.
2. Create a new branch off `main`, named `fix/<short-description>-<date>`
3. Make the smallest change that addresses the root cause - no unrelated
   refactors bundled in
4. Add or update a test that would have caught this issue, where practical
5. Run the existing test suite locally (e.g. `Invoke-Pester` for this repo,
   or the relevant app's own test command) - only proceed if it passes
6. Commit with a message that explains the root cause and the fix, not just
   "fix bug"
7. Push the branch and open a PR against `main`

## PR template to use
```
## What broke
<one-paragraph summary of the incident, linking to the diagnosis>

## Root cause
<copied from the diagnosis report>

## The fix
<what changed, and why this is the smallest safe change>

## How this was verified
<tests run, manual checks performed>

## Rollback plan
<how to revert this quickly if it turns out to be wrong>
```

## Approval gate

**Default path (almost everything lands here): manual approval, no
exceptions.** This skill never merges its own PR. Every PR waits for
Denis's explicit review - regardless of confidence level or severity.

**Fast path (the only exception, and it's narrow):** if - and only if -
*all* of the following are true, the PR may be merged automatically and
Denis is sent an alert with the merged PR link instead of being asked to
review first:
- An entry in `.claude/agents/approved-fixes/` matches the problem
  signature **exactly** (same service, same error pattern, same root
  cause classification - not "similar," exact)
- The fix stays entirely within that entry's documented file/path
  boundaries
- No new or unexpected error appears alongside the known pattern
- All tests still pass
- The entry hasn't been marked revoked (see that folder's own README)

**This skill never creates or edits an entry in `approved-fixes/`.** Only
Denis promotes a pattern to auto-approved status, by hand, after seeing it
approved manually at least twice. If there's any doubt about whether a
situation matches an existing entry, treat it as **not** a match and fall
back to the default path - false negatives (an extra manual review) are
always the safe direction to err in; false positives are not.

If the fix requires touching production secrets, infrastructure state, or
anything outside version control, stop and flag it for manual handling on
the default path, regardless of any precedent match.

## Guardrails
- Never force-push over existing history.
- Never bypass CI checks to merge faster.
- If the fix doesn't fully resolve the diagnosed root cause, say so
  explicitly in the PR rather than overstating confidence.
