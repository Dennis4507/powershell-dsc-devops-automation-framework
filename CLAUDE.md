# PowerShell DSC DevOps Automation Framework — Claude Code Context

## Who This Is For
**Denis Muriuki** — Cloud & DevOps Engineer, Kornwestheim, Germany.
GitHub: Dennis4507 | Email: riungudenis63@gmail.com

This project was created on 2026-07-08 as:
1. A portfolio piece for a Concentrix Infrastructure Automation Engineer interview (Friday 2026-07-11)
2. A genuine reusable DevOps automation framework Denis uses across his own production systems
3. A demonstration of PowerShell DSC + AI-supervised DevOps operations

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

---

## Technical Decisions Already Made

- **DSC module**: `PSDesiredStateConfiguration` (built-in, no install). Do NOT use xPSDesiredStateConfiguration unless needed for specific resources.
- **Pester version**: v5 (modern syntax — use `Should -Be`, not legacy `Should Be`)
- **No external DSC resource modules** for core config — keep dependencies minimal
- **AzureAD/Microsoft365DSC**: add as optional dependency for azure/ components only
- **Python environment**: use built-in `Script` DSC resource, not community modules
- **Config data**: `.psd1` format (PowerShell data file) — standard DSC pattern
- **One-command apply**: `Apply-ControlPlane.ps1` wraps everything
- **AI operations layer**: `.claude/agents/` skills folder — Denis's unique differentiator

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

- [ ] `windows/ControlPlane.ps1` — DSC config with 6+ resources, comment-based help
- [ ] `windows/ControlPlane.Tests.ps1` — Pester v5 tests covering all resources
- [ ] `windows/ControlPlane.config.psd1` — config data template
- [ ] `windows/Apply-ControlPlane.ps1` — one-command apply wrapper
- [ ] `.claude/agents/` — 4 skill agent files
- [ ] `README.md` — SEO-optimised, keyword-rich, badges, ASCII diagram
- [ ] `azure/main.tf` — Terraform for Azure VM + DSC Extension
- [ ] `azure/azure-ad-dsc.ps1` — Azure AD DSC config
- [ ] `linux/control-plane.yml` — Ansible equivalent
- [ ] `.github/workflows/validate-dsc.yml` — CI/CD validation
- [ ] GitHub repo created and pushed
- [ ] CV updated with DSC bullet referencing this repo
