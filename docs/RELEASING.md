# Release process

1. Update the plugin version using semantic versioning.
2. Run `scripts\Test-PluginPackage.ps1`.
3. Run `scripts\New-PluginRelease.ps1`.
4. Create a matching Git tag only after validation succeeds.
5. Attach the ZIP and SHA-256 file from `dist` to the private GitHub Release.

The release script does not push to GitHub or publish a release. Those external operations remain explicit release-owner actions.
