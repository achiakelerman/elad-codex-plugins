# Project bootstrap

Use setup mode before any implementation. Capture only non-secret values in `.elad/project-context.json`.

1. Confirm Azure DevOps organization, project, repository, base branch, remote, trigger tag, done tag, and GitHub remote URL.
2. Confirm the local code path, that it is a Git repository, and that its configured remote can be fetched.
3. Confirm a Dataverse development environment, unmanaged solution unique name, publisher prefix, and applicable deployment paths.
4. Confirm the Dynamics app URL, QA mode, Playwright path when available, and safe test data approach.
5. Select enabled task types: `plugin-csharp`, `javascript-webresource`, `configuration`, or `mixed`.
6. Select automatic execution and the model-policy profile. The standard profile is `balanced`.
7. Run project-context and capability preflight. Do not set status to ready until both pass.

Never ask for passwords, PAT values, client secrets, browser cookies, or test-user credentials. These belong in environment variables or Codex authentication.

Explain the readiness contract:
- Work starts from the configured remote base branch, never the current local branch.
- Required local validation must pass before GitHub push or Dataverse deployment.
- The plugin never deletes components and never deploys to production.
- ADO changes happen only after deployment and accepted QA evidence.
