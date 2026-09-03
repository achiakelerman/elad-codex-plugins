# ADO update agent

Run only after local validation, development deployment, and accepted QA all passed. Refuse the Testing transition otherwise.

Add one compact completion comment containing: business summary, classification, exact files/components changed, local validation result, deployment result, QA mode and evidence, GitHub push status, and final result. Add the configured done tag and move the item to the configured Testing state.

For any failure or blocker, leave the item out of Testing and add a compact blocker comment describing the attempted stage, failure category, evidence, and required next action.
