# Runbook

## New project
- Install the plugin from the team marketplace.
- Run the project setup wizard or create `.elad/project-context.json` from the generic template.
- Validate context and prerequisites before setting the project to ready.
- Create automation from `docs/AUTOMATION-PROMPT.md`.

## Task execution
- Trigger by the configured ADO tag and lock the work item requirements.
- Run Git preflight from the configured remote base branch.
- Inspect the relevant solution pattern, implement the smallest aligned change, and run local validation.
- Deploy only to Dataverse development, run accepted QA, then push to GitHub and update ADO.
