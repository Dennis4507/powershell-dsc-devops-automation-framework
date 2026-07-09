# Learning Style Guide — How We're Building This Together

This file is a reference for **how explanations should be written** in this
project while Denis is learning PowerShell/DSC from scratch. Claude should
re-read this before writing a new batch of explained code, to stay consistent.

## Who this is for
Denis — complete beginner to PowerShell and DSC. Assume **zero** prior
knowledge. Never assume a term is "obvious." Define every acronym the first
time it's used in a session, even if it was defined in an earlier session.

## Pacing: "Three by Three"
Explain **3 checklist items (DSC resources) per round**, not 1 at a time.
Within a round:
1. State the **goal** of the 3 items in one plain sentence each.
2. Show the code for all 3 together.
3. Explain shared concepts **once** (don't repeat the same explanation 3x).
4. Walk each resource's *specific* lines briefly — assume the reader now
   understands the pattern from concept explanation in step 3.
5. End with a one-sentence plain-English recap of what happens when it runs.

## Format template for every batch
```
## Round N: <short title>

### What we're building
- Item A: <one sentence, plain English>
- Item B: <one sentence, plain English>
- Item C: <one sentence, plain English>

### The code
<code block>

### New concepts (explained once)
<any new pattern/keyword introduced this round>

### Item A, line by line
...
### Item B, line by line
...
### Item C, line by line
...

### Recap
<one sentence: "when this runs, it will ___">
```

## Rules
- **Define every acronym** on first use each session: write it out in full,
  then explain what it means in plain words (e.g. "DSC = Desired State
  Configuration — Windows' built-in checklist-that-fixes-itself system").
- **Use analogies** (checklist, recipe, robot, answer sheet, toolbox) instead
  of jargon-first explanations.
- **No wall-of-code dumps** — always explain before moving to the next round.
- **Check for understanding** before continuing to the next round — end each
  round with a short question or "ready for the next round?"
- Keep code **idempotent** and consistent with the style already in
  `windows/ControlPlane.ps1`.

## Simplicity Standard v2 (raised bar — as of the pip/scheduler/SSL round)
Denis asked for *even simpler, even more detailed* explanations. From now on:
- **Explain every symbol**, not just every keyword, the first time it shows
  up: `$`, `@{ }`, `{ }`, `( )`, `[ ]`, `&`, `|`, `` ` ``, `-replace`,
  `-split`, `-like`, `-notcontains`, `-ErrorAction SilentlyContinue`, etc.
  See the **Symbol dictionary** below — add to it as new ones appear.
- **Short sentences.** One idea per sentence. Avoid stacking clauses.
- **Small chunks.** Explain code 2–5 lines at a time, never a whole
  resource in one breath.
- **Concrete example alongside the abstract.** Whenever a line uses a
  placeholder (`$using:Node.ProjectPath`), also show it with a made-up real
  value (e.g. `C:\Projects\Demo`) so the abstract line has something to
  anchor to.
- **Say the "why," not just the "what."** E.g. don't just say "this returns
  `$true`" — say *why* returning `$true` here is the right choice.
- Still keep the **Three by Three** pacing (3 resources per round) — the
  extra detail goes into *how* each is explained, not into doing fewer
  items per round.

## Symbol dictionary (append as new symbols appear)
| Symbol | Plain-English meaning |
|---|---|
| `$name` | A **variable** — a labeled box holding a value, e.g. `$venvPath` holds a folder path |
| `@{ Key = Value }` | A **hashtable** — a small bundle of labeled values, like a mini form with named fields |
| `{ }` (curly braces) | Marks the **start and end of a block** of code — "everything between these braces belongs together" |
| `( )` (parentheses) | Either "do this first" (like in math), or holds the **arguments** you're passing into a command |
| `[ ]` (square brackets) | A **type conversion** — e.g. `[bool]` means "treat/convert this as true-or-false", `[version]` means "treat this as a comparable version number" |
| `&` | "**Run this**" — tells PowerShell to execute a program/command whose name is stored in a variable or written as text |
| `\|` (pipe) | "**Take the output of the left side and feed it into the right side**" — like passing a plate down an assembly line |
| `` ` `` (backtick at end of line) | "This command **continues on the next line**" — purely for readability |
| `-replace 'X', 'Y'` | "Find text matching `X` and swap it for `Y`" |
| `-split 'X'` | "Cut the text into pieces wherever `X` appears" |
| `-like "abc*"` | "Does this text **start with** `abc`?" (`*` means "anything after this") |
| `-notcontains` | "Is this item **missing** from the list?" |
| `-ErrorAction SilentlyContinue` | "If this fails, **don't show a red error** — just quietly move on" |
| `-ge` | "greater than or equal to" |
| `$using:Name` | "Reach **outside** this block and borrow the value of `$Name` from the surrounding configuration" |
| `.Keys` | For a hashtable (labeled bundle), gives you just the **labels**, not the values. E.g. `@{ A = 1; B = 2 }.Keys` → `A`, `B` |
| `$hashtable[$key]` | "Look up the value stored under this label" — e.g. `$EnvVars['APP_ENV']` → `'production'` |

## Running glossary (append new terms here as they come up)
| Term | Plain-English meaning |
|---|---|
| PowerShell | Windows' built-in program for typing and saving commands |
| Script | A file full of saved commands (`.ps1` file) |
| DSC (Desired State Configuration) | Windows' built-in "checklist that fixes itself" system |
| Resource | One item on the DSC checklist (e.g. "Git must be installed") |
| Idempotent | Running the checklist repeatedly is always safe — it only changes what's wrong |
| LCM (Local Configuration Manager) | The "robot" built into Windows that reads the checklist and checks/fixes the computer |
| MOF file | The compiled, robot-readable version of our checklist script |
| Node | DSC's word for "a computer this checklist applies to" |
| `Configuration` block | Names and defines the whole checklist |
| `Import-DscResource` | Opens the "toolbox" of checklist-item types we're allowed to use |
| `Ensure = 'Present'/'Absent'` | Says whether something should exist or should be removed |
| `File` resource | Built-in checklist-item type for "this file/folder should(n't) exist" — Test/Set/Get logic is pre-written by Microsoft |
| `Script` resource | Checklist-item type for anything custom — **we** write the Test/Set/Get logic ourselves |
| Test / Set / Get pattern | Test = "is it already correct?", Set = "fix it" (only runs if Test said no), Get = "report current status" |
| `$Node.SomeValue` | Placeholder that pulls a real value from the "answer sheet" (config data file) at run time |
| `.psm1` file / module | A toolbox file of reusable functions other files can `Import-Module` and call |
| `Pester` | PowerShell's testing tool - runs small checks against code and reports pass/fail |
| `Mock` (in a Pester test) | Fake the answer to something risky/slow (e.g. "pretend Git isn't installed") instead of doing it for real |
| `try { } catch { }` | "Try this code; if it fails, jump to the catch block instead of crashing" |
| `param()` | Declares the inputs a script or function accepts |

## Gotchas learned along the way
- **No fancy punctuation in `.ps1` files.** Windows PowerShell 5.1 reads
  files without a byte-order-mark (BOM) using the legacy system codepage,
  not UTF-8. Characters like em-dashes (`—`) or smart quotes get misread as
  different characters and can silently break string literals. Stick to
  plain ASCII punctuation (`-`, `'`, `"`) in script files. Verify with:
  `[System.Management.Automation.Language.Parser]::ParseFile(path, [ref]$null, [ref]$errors)`

## Progress tracker
See the in-session TodoWrite list for live status. High-level build order
lives in `CLAUDE.md` under "Build Priority Order."
