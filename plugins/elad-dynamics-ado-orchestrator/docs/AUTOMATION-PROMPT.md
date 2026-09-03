Use ELAD Dynamics Orchestrator on a schedule for the current project only.

For each run, load the ready project context and capability report. Query Azure DevOps only for active work carrying the configured trigger tag. Process one item at a time using Git preflight from the configured remote base branch, locked ADO requirements, narrow code context, the selected specialist, and configured local validation.

Never deploy to Dataverse or push GitHub before local validation passes. Deploy only to the configured development environment. Run Playwright QA by default; use documented manual QA only when browser authentication blocks automation. Add the completion tag and transition ADO to Testing only after deployment and accepted QA evidence. For a blocker, add a compact blocker comment and leave the work item out of Testing.
