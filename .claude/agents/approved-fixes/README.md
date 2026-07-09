# Approved Fixes Library

This folder is the **only** thing that lets `remediation-pr` skip waiting
for manual approval. It's a small library of problem-and-solution pairs
that Denis has personally approved before, more than once, and explicitly
decided are safe to auto-merge the next time the exact same thing happens.

## The core rule

**Nothing in here gets added automatically.** The `remediation-pr` skill
can *read* this folder to check for a match - it can never *write* to it.
Only Denis adds, edits, or revokes an entry, by hand, as a deliberate
decision.

## How a fix graduates into this folder

1. A real incident happens. `incident-diagnosis` diagnoses it,
   `remediation-pr` opens a PR on the normal, manual-approval path.
2. Denis reviews and approves it, as usual.
3. The **exact same problem signature** happens again, later. Same
   manual-approval process, same fix.
4. After that pattern has been manually approved **at least twice**, Denis
   may choose to add it here - writing down precisely what qualifies as a
   match, and precisely what the approved fix is allowed to touch.
5. From that point on, that specific, narrow pattern can auto-merge. Any
   deviation from the documented signature still goes through full manual
   review.

## Entry format

Each entry is its own file, named `<short-slug>.md`, containing:
- **Problem signature** - the exact conditions that must all be true for
  this to count as a match (service, error pattern, root cause)
- **Approved solution** - the exact, scope-limited fix
- **Boundaries** - what immediately disqualifies a match, even if the
  problem signature looks similar
- **Reference PRs** - links to the manually-approved PRs that established
  this precedent
- **Status** - `Approved` or `Revoked` (Denis can revoke an entry at any
  time - once revoked, that pattern permanently falls back to manual
  review until re-approved from scratch)

## Why this is deliberately narrow

The goal isn't to reduce how often Denis reviews things - it's to remove
manual review *only* for the small set of situations that have already
proven, repeatedly, to be safe, well-understood, and narrow in scope.
Every auto-merge still runs the full test suite, still opens a real PR
with a real diff, and still sends Denis an immediate alert with a link -
nothing happens silently. If there's ever doubt about whether something
matches, the fallback is always the manual path, never the fast path.
