# Model routing policy

Read this only after a project context is ready.

The configured profile is `balanced` unless the project overrides it. Use the model tier as a workload contract, not a guarantee that Codex can switch models inside the current task.

- `routine`: ADO intake, classification, Git preflight, narrow code search, artifact formatting, and compact ADO comments.
- `strategic`: requirement ambiguity, implementation plan, cross-component design, assembly and registration selection, deployment approval, QA evaluation, and ADO transition.
- `execution`: the selected specialist's bounded implementation after strategic planning has locked targets and acceptance criteria.

When Codex exposes a supported task handoff with model and thinking selection, create the handoff using the configured tier. Otherwise record `routingMode: advisory` in the task artifact, remain in the current task, and keep the prompt and context limited to that tier's inputs.
