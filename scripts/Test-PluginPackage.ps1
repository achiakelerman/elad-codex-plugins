[CmdletBinding()]
param(
  [string]$RepositoryPath = (Split-Path -Parent $PSScriptRoot)
)

$repositoryPath = (Resolve-Path -LiteralPath $RepositoryPath -ErrorAction Stop).Path
$pluginName = 'elad-dynamics-ado-orchestrator'
$pluginPath = Join-Path $repositoryPath "plugins\$pluginName"
$marketplacePath = Join-Path $repositoryPath '.agents\plugins\marketplace.json'
$manifestPath = Join-Path $pluginPath '.codex-plugin\plugin.json'
$errors = [System.Collections.Generic.List[string]]::new()

function Read-Json([string]$Path) {
  try { return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop }
  catch { $errors.Add("Invalid JSON: $Path - $($_.Exception.Message)"); return $null }
}

foreach ($path in @($pluginPath, $marketplacePath, $manifestPath, (Join-Path $pluginPath '.mcp.json'), (Join-Path $pluginPath 'skills'))) {
  if (-not (Test-Path -LiteralPath $path)) { $errors.Add("Missing required path: $path") }
}

$marketplace = if (Test-Path -LiteralPath $marketplacePath) { Read-Json $marketplacePath }
$manifest = if (Test-Path -LiteralPath $manifestPath) { Read-Json $manifestPath }
if ($marketplace) {
  $entry = @($marketplace.plugins | Where-Object { $_.name -eq $pluginName })
  if ($entry.Count -ne 1) { $errors.Add("Marketplace must contain exactly one $pluginName entry") }
  elseif ($entry[0].source.path -ne "./plugins/$pluginName") { $errors.Add('Marketplace source path is invalid') }
}
if ($manifest) {
  if ($manifest.name -ne $pluginName) { $errors.Add('Manifest name does not match plugin folder') }
  if ($manifest.version -notmatch '^\d+\.\d+\.\d+([+-][0-9A-Za-z.-]+)?$') { $errors.Add('Manifest version is not semantic versioning') }
  if (-not $manifest.author.name -or -not $manifest.interface.displayName -or -not $manifest.interface.developerName) { $errors.Add('Manifest branding is incomplete') }
}

$agentMetadataPath = Join-Path $pluginPath 'skills\elad-dynamics-ado-operator\agents\openai.yaml'
if (Test-Path -LiteralPath $agentMetadataPath) {
  if (Select-String -LiteralPath $agentMetadataPath -Pattern '^\s*category\s*:' -Quiet) {
    $errors.Add('Agent metadata contains unsupported interface.category')
  }
}

$nestedMarketplaces = Get-ChildItem -LiteralPath $pluginPath -Filter marketplace.json -Recurse -File -ErrorAction SilentlyContinue
if ($nestedMarketplaces) { $errors.Add('Plugin package must not contain a nested marketplace.json') }

$forbidden = @('TAMC-Ichilov', 'master_achia', 'd365tlvmc-dev', '958b948b-b21b-f111-8342-7ced8d2e54a8')
$textFiles = Get-ChildItem -LiteralPath $pluginPath -Recurse -File -Include *.md,*.json,*.yaml,*.py,*.ps1 -ErrorAction SilentlyContinue
foreach ($term in $forbidden) {
  $matches = $textFiles | Select-String -SimpleMatch -Pattern $term -ErrorAction SilentlyContinue
  if ($matches) { $errors.Add("Project-specific content found: $term") }
}

$validator = Join-Path $pluginPath 'skills\elad-dynamics-ado-operator\scripts\validate_project_context.py'
$example = Join-Path $pluginPath 'examples\project-context.example.json'
if ((Test-Path -LiteralPath $validator) -and (Test-Path -LiteralPath $example)) {
  & python $validator $example | Out-Host
  if ($LASTEXITCODE -ne 0) { $errors.Add('Generic project-context example does not pass validation') }
}

$report = [ordered]@{
  passed = ($errors.Count -eq 0)
  repositoryPath = $repositoryPath
  pluginPath = $pluginPath
  errors = $errors
  checkedAt = (Get-Date).ToUniversalTime().ToString('o')
}
$report | ConvertTo-Json -Depth 8
if ($errors.Count -gt 0) { exit 1 }
