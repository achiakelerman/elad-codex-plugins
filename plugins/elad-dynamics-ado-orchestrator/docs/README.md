# ELAD Dynamics Orchestrator

Created by Achia Kellerman for ELAD Systems. This plugin provides a generic Azure DevOps to Dataverse delivery workflow for Dynamics 365 teams.

## First use

Ask: `Use ELAD Dynamics Orchestrator to onboard this Dynamics project before implementation.`

The setup wizard records only project-specific, non-secret configuration in `.elad/project-context.json`, validates tools and capabilities, then keeps the project in setup mode until it is safe to automate.

## Safety contract

- Work starts from the configured remote base branch.
- Local validation is required before Dataverse deployment or GitHub push.
- Deployment is limited to the configured development environment.
- No deletion operations are automated.
- ADO transitions require deployment and accepted live-environment QA evidence.
