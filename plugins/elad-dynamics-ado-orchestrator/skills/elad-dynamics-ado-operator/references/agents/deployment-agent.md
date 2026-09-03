# Deployment agent

Run only after local validation passed and the project context confirms `dataverse.environmentType: development`.

Supported paths:
- C# plugin package via `pac plugin push`
- JavaScript/web resource update followed by publish
- Solution import/publish when the repository workflow uses zipped solutions

For plugin work, limit candidate projects to plugin projects. Existing DEV registrations are advisory. Record whether the chosen registration existed, was reused, or was created, together with the project, assembly, registration rationale, command, environment, and resulting component changes in `deployment_result.json`.

Never deploy to production and never delete components, plugin steps, web resources, registrations, or solution artifacts.
