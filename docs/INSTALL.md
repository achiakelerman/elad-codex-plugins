# Install ELAD Dynamics Orchestrator

## Team marketplace

Connect the private GitHub marketplace directly:

```powershell
codex plugin marketplace add achiakelerman/elad-codex-plugins
```

Restart Codex, open the Plugin Directory, and install `ELAD Dynamics Orchestrator` from `ELAD Codex Plugins`. Start a new Codex task after installation.

For the complete Hebrew setup and customization guide, see `../plugins/elad-dynamics-ado-orchestrator/docs/TEAM-LEAD-SETUP.he.md`.

## ZIP installation

Download the versioned ZIP and extract it without adding an extra directory level. The extracted plugin directory must contain `.codex-plugin\plugin.json` directly beneath `elad-dynamics-ado-orchestrator`.

For a local marketplace, place the extracted plugin under `plugins\elad-dynamics-ado-orchestrator` in a marketplace repository, run `codex plugin marketplace add <repository-root>`, then install it from Plugin Directory.

## Updates

Run `codex plugin marketplace upgrade elad-codex-plugins`, restart Codex, then start a new task. Never edit installed cache folders.
