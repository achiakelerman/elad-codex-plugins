[CmdletBinding()]
param(
  [string]$RepositoryPath = (Split-Path -Parent $PSScriptRoot)
)

$repositoryPath = (Resolve-Path -LiteralPath $RepositoryPath -ErrorAction Stop).Path
$testScript = Join-Path $repositoryPath 'scripts\Test-PluginPackage.ps1'
& $testScript -RepositoryPath $repositoryPath
if ($LASTEXITCODE -ne 0) { throw 'Release blocked: package validation failed.' }

$pluginName = 'elad-dynamics-ado-orchestrator'
$pluginPath = Join-Path $repositoryPath "plugins\$pluginName"
$manifest = Get-Content -LiteralPath (Join-Path $pluginPath '.codex-plugin\plugin.json') -Raw | ConvertFrom-Json
$distPath = Join-Path $repositoryPath 'dist'
$archivePath = Join-Path $distPath "$pluginName-$($manifest.version).zip"
$hashPath = "$archivePath.sha256"
New-Item -ItemType Directory -Path $distPath -Force | Out-Null
Compress-Archive -LiteralPath $pluginPath -DestinationPath $archivePath -Force
$hash = Get-FileHash -LiteralPath $archivePath -Algorithm SHA256
[System.IO.File]::WriteAllText($hashPath, "$($hash.Hash.ToLowerInvariant())  $(Split-Path -Leaf $archivePath)`n", [System.Text.UTF8Encoding]::new($false))
[pscustomobject]@{ archive = $archivePath; sha256 = $hash.Hash.ToLowerInvariant(); checksumFile = $hashPath } | ConvertTo-Json
