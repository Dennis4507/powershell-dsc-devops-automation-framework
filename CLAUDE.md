# PowerShell DSC DevOps Automation Framework — Claude Code Context

## Who This Is For
**Denis Muriuki** — Cloud & DevOps Engineer, Kornwestheim, Germany.
GitHub: Dennis4507 | Email: riungudenis63@gmail.com

This project was created on 2026-07-08 as:
1. A portfolio piece for a Concentrix Infrastructure Automation Engineer interview (Friday 2026-07-11)
2. A genuine reusable DevOps automation framework Denis uses across his own production systems
3. A demonstration of PowerShell DSC + AI-supervised DevOps operations

---

## Business Goal & Direction — Read This Before Writing Any Code

### The Real Production Problem
Denis operates multiple production projects from ONE Windows machine (the control plane):
- HeRiko eBay Platform — Hetzner K3s, 12 services (FastAPI, Celery, CLIP/FAISS, PostgreSQL, Prometheus, Grafana, Loki, Sentry, Alertmanager, EfficientNet)
- HeRiko WooCommerce — AWS, 50,000 products
- Knowledge Base + AI Interview Assistant — local FastAPI
- Client work — neighbour Amazon seller deploying ecommerce to cloud

**Nothing enforces that Windows machine stays in the correct state.** If Python breaks, a venv disappears, a Task Scheduler job vanishes, or an env var resets — Denis fixes it manually. DSC is the fix.

---

### The 3-Layer Model (anchor everything here)

Layer 1 — ENVIRONMENT (DSC)
"Is this Windows machine configured correctly to do the work?"
→ Python, Git, venv, Task Scheduler, SSL certs, env vars — enforced idempotently

Layer 2 — OPERATIONS (CLAUDE.md + skills library)
"Are the apps healthy? Fix problems automatically."
→ Prometheus/Sentry fires → Claude diagnoses → skills agent creates PR → Denis approves

Layer 3 — DEPLOYMENT (GitHub Actions + Terraform)
"Get code and infrastructure to where it needs to be."
→ CI/CD, IaC, zero-downtime deploys



These layers are **independent**. DSC doesn't know about CLAUDE.md. Each answers one question. Together they form a complete autonomous DevOps system.

---

### The Widget Concept
Drop this framework into any project — Denis's own or a client's:
1. Clone repo
2. Edit `ControlPlane.config.psd1` — 5 minutes
3. Run `.\Apply-ControlPlane.ps1`
→ Any Windows machine becomes a DevOps control plane.

**Real client scenario:** Denis's neighbour is an Amazon seller. Denis arrives (or connects remotely), drops the framework on the neighbour's machine, edits the psd1, runs one command. Machine is provisioned. Denis deploys the app via Terraform + GitHub Actions. Neighbour never touches infrastructure.

This is what Concentrix does for enterprise clients. Same pattern, different scale.

---

### Two Goals — Both Matter
1. **PRODUCTION**: Reproducible Windows control plane. Used across all Denis's projects and client work.
2. **CV/PORTFOLIO**: Concentrix interview Friday 2026-07-11. Proves DSC, Pester, PSScriptAnalyzer, GitHub Actions, plug-and-play architecture delivery.

---

### Build Philosophy — The Guardrail
**Build these 4 files first. They are the real deliverable:**
1. `windows/ControlPlane.ps1` — DSC configuration
2. `windows/ControlPlane.Tests.ps1` — Pester v5 tests
3. `windows/ControlPlane.config.psd1` — config data
4. `windows/Apply-ControlPlane.ps1` — one-command wrapper

**If those 4 are done, the project is real and usable.** Everything else is bonus.
Do NOT add complexity for its own sake. Every file must solve a real problem Denis has today.

---

## What This Project Is

A **plug-and-play PowerShell DSC framework** that enforces desired state of Windows DevOps control planes and integrates with an AI-supervised operations model (Claude Code + CLAUDE.md + skills library).

Drop it into any project and get:
- **Windows desired state enforcement** (Python runtime, Git, tools, Task Scheduler, SSL certs, env vars)
- **AI-supervised operations** (CLAUDE.md guardrails + skills agents)
- **Azure VM provisioning + DSC** (Terraform + Azure VM DSC Extension)
- **Azure AD configuration via DSC** (Microsoft365DSC/AzureAD module)
- **Linux equivalent** (Ansible playbook mirrors DSC config)
- **CI/CD validation** (GitHub Actions tests DSC on every PR)
- **Pester tests** (unit + integration for all DSC resources)

---

## Complete File Structure to Build

```
powershell-dsc-devops-automation-framework/
├── CLAUDE.md                              ← This file (project context)
├── README.md                              ← Public documentation (SEO-optimised)
│
├── .claude/
│   └── agents/                            ← Skills library (AI agent workflows)
│       ├── 01-incident-diagnosis.md       ← Diagnose any alert/incident
│       ├── 02-remediation-pr.md           ← Create fix PR automatically
│       ├── 03-cost-drift-analysis.md      ← FinOps + cloud cost analysis
│       └── 04-pipeline-health.md          ← CI/CD pipeline validation
│
├── windows/
│   ├── ControlPlane.ps1                   ← MAIN DSC configuration
│   ├── ControlPlane.Tests.ps1             ← Pester tests (unit + integration)
│   ├── ControlPlane.config.psd1           ← Configuration data (edit per project)
│   └── Apply-ControlPlane.ps1             ← One-command wrapper script
│
├── linux/
│   └── control-plane.yml                  ← Ansible equivalent of DSC config
│
├── azure/
│   ├── main.tf                            ← Terraform: Azure VM + DSC Extension
│   ├── variables.tf                       ← VM size, region, project name vars
│   ├── outputs.tf                         ← VM IP, DSC status outputs
│   └── azure-ad-dsc.ps1                   ← Azure AD / Entra ID DSC config
│
├── docs/
│   ├── how-to-plug-in.md                  ← Step-by-step plug-and-play guide
│   └── azure-vm-setup.md                  ← Azure VM + DSC Extension guide
│
└── .github/
    └── workflows/
        └── validate-dsc.yml               ← Tests DSC syntax + Pester on PR
```

---

## Build Priority Order (Interview is Friday 2026-07-11)

Build in this exact order — most important first:

### 1. `windows/ControlPlane.ps1` — HIGHEST PRIORITY
The core DSC configuration. Enforces desired state of:
- Git installed and on PATH
- Python 3.11+ installed
- Virtual environment exists at `$ProjectPath\.venv`
- Required pip packages installed from requirements.txt
- Windows Task Scheduler jobs registered (from a jobs config)
- SSL certificate files present (warns if missing, does not auto-generate)
- Required environment variables set
- Project directory exists

Use `PSDesiredStateConfiguration` module (built into Windows — no install needed).
Use `Script` resources for custom logic (Get/Test/Set pattern).
Use `File` resources for file/directory enforcement.
Use `Environment` resources for env vars.
Use comment-based help at the top.
Every resource must be idempotent — running twice produces same result.

### 2. `windows/ControlPlane.Tests.ps1` — HIGH PRIORITY
Pester v5 tests. Test each DSC resource independently:
- Mock the `Get-Command` for Python, Git
- Test that TestScript returns $true when state is correct
- Test that TestScript returns $false when state is wrong
- Test that SetScript makes the correct calls
Use `Describe`, `Context`, `It`, `Should`, `Mock` blocks.

### 3. `windows/ControlPlane.config.psd1` — HIGH PRIORITY
Configuration data file. This is what users edit per-project:
```powershell
@{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            ProjectName = 'MyProject'
            ProjectPath = 'C:\Projects\MyProject'
            PythonVersion = '3.11'
            VenvName = '.venv'
            RequirementsFile = 'requirements.txt'
            ScheduledJobs = @(
                @{ Name = 'DailyMaintenance'; Script = 'scripts\daily.bat'; Time = '06:30' }
            )
            SSLCertPath = 'certs'
            EnvVars = @{
                APP_ENV = 'production'
            }
        }
    )
}
```

### 4. `windows/Apply-ControlPlane.ps1` — HIGH PRIORITY
One-command wrapper:
```powershell
# Apply-ControlPlane.ps1
# Run this to enforce desired state on this machine
. .\ControlPlane.ps1
ControlPlane -ConfigurationData .\ControlPlane.config.psd1 -OutputPath .\MOF
Start-DscConfiguration -Path .\MOF -Wait -Verbose -Force
```
Include error handling, prerequisite checks, and output formatting.

### 5. `.claude/agents/` — HIGH PRIORITY (Denis's unique differentiator)

#### `01-incident-diagnosis.md`
When an alert fires: read logs → identify pattern → check knowledge base → propose fix.
Structure: trigger conditions, what to read, how to diagnose, what to output.

#### `02-remediation-pr.md`
After diagnosis: create a branch → write the fix → run tests → open PR → notify.
Structure: inputs needed, steps, PR template, approval gate.

#### `03-cost-drift-analysis.md`
Analyse cloud costs: query AWS Cost Explorer or Azure Cost Management → compare to baseline → flag anomalies → suggest optimisations.

#### `04-pipeline-health.md`
Check CI/CD: query GitHub Actions or GitLab CI → identify failing stages → check logs → propose fix.

### 6. `README.md` — HIGH PRIORITY (SEO + ATS)
Must contain these sections:
- **Title**: PowerShell DSC DevOps Automation Framework
- **Badges**: PowerShell version, Pester, GitHub Actions status, license
- **What it does** (2 sentences, keyword-rich)
- **Architecture diagram** (ASCII)
- **Quick Start** (clone → edit config → run Apply-ControlPlane.ps1)
- **Components** (DSC, Skills Library, Azure, Linux/Ansible)
- **Plug-and-play guide** (how to add to any project)
- **Tech stack** (PowerShell DSC, Pester, Ansible, Terraform, Azure VM DSC Extension, GitHub Actions)
- **Roadmap** (Microsoft365DSC, Azure AD, drift alerts)

Keywords to include naturally: PowerShell DSC, Desired State Configuration, DevOps automation, infrastructure as code, Windows, Azure, CI/CD, Pester, idempotent, LCM, configuration drift.

### 7. `azure/main.tf` — MEDIUM PRIORITY
Terraform that provisions:
- Resource group
- Windows Server 2022 VM (B2s — cheap, stoppable)
- Public IP (optional)
- **Azure VM DSC Extension** pointing to ControlPlane.ps1
- Storage account for DSC MOF files

Variables: location, vm_size, admin_username, project_name.

### 8. `azure/azure-ad-dsc.ps1` — MEDIUM PRIORITY
DSC configuration using AzureAD or Microsoft365DSC module:
- Ensure a service principal exists for the project
- Ensure RBAC role assignment
- Ensure app registration

This demonstrates Microsoft365DSC knowledge (listed as preferred in Concentrix JD).

### 9. `linux/control-plane.yml` — MEDIUM PRIORITY
Ansible playbook that mirrors ControlPlane.ps1 for Linux:
- Install Python, Git, Docker
- Create virtual environment
- Register cron jobs (equivalent of Task Scheduler)
- Set environment variables
- Validate SSL cert presence

### 10. `.github/workflows/validate-dsc.yml` — MEDIUM PRIORITY
GitHub Actions workflow:
- Trigger: push/PR to main
- Runner: windows-latest
- Steps: Install Pester → Run Pester tests → Validate DSC syntax (PSScriptAnalyzer) → Report results

**⚠️ Reminder when building this:** this file is currently listed in
`.gitignore` (our GitHub access token lacks `workflow` scope, so pushing
any change to `.github/workflows/*` gets rejected). Before writing real
content here, either fix the token's scope or be ready to do so - and
**remove the `.gitignore` line for this file**, otherwise the real content
will be silently ignored by git and never actually get pushed.

---

## Technical Decisions Already Made

- **DSC module**: `PSDesiredStateConfiguration` (built-in, no install). Do NOT use xPSDesiredStateConfiguration unless needed for specific resources.
- **Pester version**: v5 (modern syntax — use `Should -Be`, not legacy `Should Be`)
- **No external DSC resource modules** for core config — keep dependencies minimal
- **AzureAD/Microsoft365DSC**: add as optional dependency for azure/ components only
- **Microsoft365DSC runs on the Azure VM, never on a personal machine**: it needs significant disk space (1-2+ GB with dependencies) and holds access to a client's tenant, so it belongs on the same dedicated Azure VM that `azure/main.tf` provisions for the Windows checklist - not on Denis's own PC. See `docs/m365-dsc-production-notes.md`.
- **Python environment**: use built-in `Script` DSC resource, not community modules
- **Config data**: `.psd1` format (PowerShell data file) — standard DSC pattern
- **One-command apply**: `Apply-ControlPlane.ps1` wraps everything
- **AI operations layer**: `.claude/agents/` skills folder — Denis's unique differentiator
- **No Azure App Service, ever, for the trigger/wiring layer**: the future trigger listener (what will notice a real alert and start a skill) must run on the same Azure VM that `azure/main.tf` provisions, not a separate App Service. The whole point of this project is that nothing runs on infrastructure DSC isn't watching — a separate App Service would sit outside that trust boundary. Once built, the listener gets its own `ControlPlane.ps1` checklist item, the same Test/Set pattern as everything else, so DSC watches it too.

---

## Context: Denis's Existing Production System

This framework was designed around Denis's actual production environment:

**HeRiko AI/ML Platform** (12 services on Hetzner K3s):
- Windows control plane running: Claude Code, Knowledge Base FastAPI app, job schedulers
- Existing PowerShell: `schedule_jobs.ps1`, `unschedule_jobs.ps1` (Task Scheduler automation)
- Existing CI/CD: GitHub Actions (`deploy-all.yml`) for Docker build/push/deploy
- Monitoring: Prometheus + Grafana (infra) + Sentry (app layer)
- AI operations: Claude Code + CLAUDE.md guardrails + skills library

The DSC config enforces the Windows control plane stays in correct state.
The skills agents automate the same incident → diagnosis → remediation → PR workflow.

---

## Concentrix JD Keywords to Hit

The framework must demonstrate (from the actual JD):
- ✅ PowerShell (advanced functions, modules, error handling)
- ✅ DSC resources (idempotent Get/Test/Set, LCM, drift detection)
- ✅ CI/CD pipelines (GitHub Actions for DSC validation)
- ✅ Pester testing (unit + integration)
- ✅ PSScriptAnalyzer (code quality in CI)
- ✅ Open-source collaboration (GitHub repo, README, contribution hygiene)
- ✅ Documentation in Markdown (README, docs/)
- ✅ Customer-facing architecture (plug-and-play design = self-service for clients)
- ✅ Azure DevOps/GitHub Actions (validate-dsc.yml)
- ✅ Microsoft365DSC (azure-ad-dsc.ps1)
- ✅ Secrets management (note in config: never store secrets in psd1)

---

## How to Connect to GitHub

```powershell
# After building, push to GitHub:
gh repo create powershell-dsc-devops-automation-framework --public --description "Plug-and-play PowerShell Desired State Configuration framework for Windows DevOps control planes"
git add .
git commit -m "Initial: PowerShell DSC DevOps Automation Framework"
git push -u origin main
```

---

## Server / Operations Rules (from main KB project)

- Do NOT restart any running services without Denis confirming
- TLS interception active — use `--no-verify-ssl` for AWS CLI, `truststore.inject_into_ssl()` for Python
- Use PowerShell tool for network operations (Bash has no network)
- Never paste passwords or secrets into files

---

## What "Done" Looks Like

- [x] `windows/ControlPlane.ps1` — DSC config, 8 checklist items, comment-based help
- [x] `windows/ControlPlane.Helpers.psm1` — testable logic, extracted for real unit testing
- [x] `windows/ControlPlane.Tests.ps1` — Pester tests covering all resources (15/15 passing)
- [x] `windows/ControlPlane.config.psd1` — config data template
- [x] `windows/Apply-ControlPlane.ps1` — one-command apply wrapper
- [x] `.claude/agents/` — 4 skill agent files + `approved-fixes/` precedent library
- [x] `README.md` — full narrative, real screenshots, 3-layer framing
- [x] `azure/azure-ad-dsc.ps1` — Microsoft 365/Azure AD DSC skeleton (not yet run against a real tenant — see `docs/m365-dsc-production-notes.md`)
- [x] `azure/main.tf` + `variables.tf` + `outputs.tf` — Terraform for the Azure VM (not yet run with `terraform apply` — no Terraform CLI or Azure credentials used tonight, this creates real billed resources)
- [x] `azure/install-microsoft365dsc.yml` + `inventory.example.ini` — Ansible playbook that fully automates installing Microsoft365DSC on the VM over WinRM (not yet run against a real VM, since none exists yet)
- [x] `linux/control-plane.yml` — Ansible equivalent of the Windows checklist, syntax-checked via WSL (not yet run against a real Linux machine)
- [x] `.github/workflows/validate-dsc.yml` — real CI content, pushed and live
- [x] `docs/how-to-plug-in.md` — step-by-step guide, real example, links to section 11 for troubleshooting
- [x] GitHub repo created and pushed
- [ ] **The trigger/wiring layer** — nothing yet automatically connects a real
      alert (Sentry, Prometheus, a failed GitHub Actions run) to actually
      invoking a skill. This is the single biggest remaining gap between
      "skills are written" and "98% of DevOps work is actually automated."
      Belongs on the same Azure VM that `azure/main.tf` provisions.
      **Decision: pull-based first, not push/webhook.** A scheduled task on
      the VM polls Prometheus's and Sentry's own APIs on an interval (e.g.
      every 5 minutes) rather than exposing an inbound webhook endpoint on
      the VM. Simpler, no open door on the internet, no signature
      verification to get right. Trade-off: a small delay (up to one poll
      interval) instead of instant notification. Push-based webhooks
      (Alertmanager receivers, Sentry webhooks) can be added later for
      Alertmanager specifically, once the simpler pull version is proven
      safe in practice - not before.
- [ ] Actually run `terraform apply` against a real Azure subscription, once reviewed and ready to incur real cost
- [ ] CV updated with DSC bullet referencing this repo
