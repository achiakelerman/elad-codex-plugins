---
name: elad-dynamics-ado-operator
description: onboard and automate safe Azure DevOps to Dataverse delivery for any ELAD Dynamics 365 project.
---

# ELAD Dynamics Orchestrator

Created by Achia Kellerman for ELAD Systems.

## Prime directive
Start every new project in setup mode. Do not implement code until project context and capability preflight both report `ready`.

## Setup mode
When `.elad/project-context.json` is absent or invalid:
1. Load `references/project-bootstrap.md` and ask only for missing non-secret values.
2. Create `.elad/project-context.json` from `config/project-context.template.json`, or use `scripts/windows/Initialize-ProjectContext.ps1`.
3. Run `scripts/validate_project_context.py .elad/project-context.json`.
4. Run `scripts/windows/Test-ProjectPrerequisites.ps1` and save `capability_report.json`.
5. Keep status `setup-required` if values, tools, declared MCP configuration, or required specialist capabilities are missing.
6. Never store credentials in the project context.

## Execution mode
Process one work item at a time after readiness succeeds:
1. Load `references/agents/orchestrator-agent.md`, `ado-intake-agent.md`, and `task-classifier-agent.md` with the routine model tier.
2. Run `scripts/windows/Start-GitPreflight.ps1` before code-context analysis. The prior branch is informational only; the task branch starts from the configured remote and base branch.
3. Load `code-context-agent.md` and report exact candidate files.
4. Use the strategic model tier for requirement ambiguity, plans, architecture, target assembly/registration, deployment, QA evaluation, and ADO transition.
5. Load only the selected specialist agent. Use the execution tier for its bounded implementation.
6. Run `Invoke-LocalValidation.ps1`. Do not push to GitHub or deploy to Dataverse before it passes.
7. Load `deployment-agent.md`; deploy only to the configured Dataverse development environment.
8. Load `qa-agent.md`. Playwright is the default; documented manual QA is valid only when browser authentication blocks automation.
9. Push to GitHub only after QA passes. Then load `ado-update-agent.md`, add evidence, tag the item, and move it to Testing.

## Hard rules
- Never infer requirements from DEV registrations, local branch names, or the checked-out branch.
- Never deploy or push before local validation passes.
- Never deploy to a non-development Dataverse environment.
- Never delete files, solution components, plugin steps, web resources, or registrations.
- Never replace an existing pattern when a minimal aligned change is possible.
- Never update ADO to Testing without deployment and accepted QA evidence.

## Required outputs
Produce compact UTF-8 artifacts whenever applicable:
- `project_setup_report.json`
- `capability_report.json`
- `git_preflight_report.json`
- `ado_task_brief.json`
- `task_classification.json`
- `code_context_report.json`
- `deployment_result.json`
- `qa_validation_report.json`
- `ado_update_result.json`

## Key files
- `references/project-bootstrap.md`
- `references/model-routing.md`
- `references/agents/<only the required agent>.md`
- `config/project-context.template.json`
- `docs/AUTOMATION-PROMPT.md`
- `scripts/validate_project_context.py`
