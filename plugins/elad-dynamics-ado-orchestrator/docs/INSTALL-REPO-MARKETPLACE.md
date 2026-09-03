# Install from a team marketplace

1. Clone the `elad-codex-plugins` repository locally.
2. Confirm the repository root contains `.agents/plugins/marketplace.json` and `plugins/elad-dynamics-ado-orchestrator`.
3. Run `codex plugin marketplace add <repository-root>`.
4. Run `codex plugin add elad-dynamics-ado-orchestrator@elad-codex-plugins`.
5. Start a new Codex task before using the updated plugin.
