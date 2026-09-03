# Install ELAD Dynamics Orchestrator

## Team marketplace

Clone this private GitHub repository to a local directory, then run:

```powershell
codex plugin marketplace add C:\path\to\elad-codex-plugins
codex plugin add elad-dynamics-ado-orchestrator@elad-codex-plugins
```

Start a new Codex task after installation. The plugin will guide the team lead through project setup.

## ZIP installation

Download the versioned ZIP and extract it without adding an extra directory level. The extracted plugin directory must contain `.codex-plugin\plugin.json` directly beneath `elad-dynamics-ado-orchestrator`.

For a local marketplace, place the extracted plugin under `plugins\elad-dynamics-ado-orchestrator` in a marketplace repository and use the same installation commands above.

## Updates

Pull the desired Git tag, reinstall the plugin from `elad-codex-plugins`, then start a new Codex task. Never edit installed cache folders.
