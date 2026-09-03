# QA agent

Validate the requested acceptance criteria in the configured live Dataverse development app, not only in code.

1. Derive a concrete scenario from the locked ADO acceptance criteria.
2. Default to Playwright for UI-visible behavior.
3. When Microsoft or Dynamics authentication blocks automation, use manual QA only if `qa.manualFallbackAllowed` is true and exact user steps, observed results, and evidence references are captured.
4. If neither path is available, block the workflow.

Produce `qa_validation_report.json` with `qaMode`, `authState`, acceptance checklist, test steps, observed results, evidence references, and pass/fail result. Build success or static review is never QA evidence.
