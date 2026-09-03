[CmdletBinding()]
param(
  [string]$RepositoryPath = (Split-Path -Parent $PSScriptRoot)
)

$pluginPath = Join-Path $RepositoryPath 'plugins\elad-dynamics-ado-orchestrator'
$validator = Join-Path $pluginPath 'skills\elad-dynamics-ado-operator\scripts\validate_project_context.py'
$examplePath = Join-Path $pluginPath 'examples\project-context.example.json'
$temporaryPath = Join-Path ([System.IO.Path]::GetTempPath()) "elad-project-context-$([guid]::NewGuid()).json"
try {
  & python $validator $examplePath
  if ($LASTEXITCODE -ne 0) { throw 'Expected generic example to pass validation.' }

  $configurationOnly = Get-Content -LiteralPath $examplePath -Raw | ConvertFrom-Json
  $configurationOnly.workflow.enabledTaskTypes = @('configuration')
  $configurationOnly.deployment.pluginProjectPath = ''
  $configurationOnly.deployment.webResourceRoot = ''
  [System.IO.File]::WriteAllText($temporaryPath, ($configurationOnly | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
  & python $validator $temporaryPath | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Expected configuration-only context to pass validation.' }

  $pluginOnly = Get-Content -LiteralPath $examplePath -Raw | ConvertFrom-Json
  $pluginOnly.workflow.enabledTaskTypes = @('plugin-csharp')
  $pluginOnly.deployment.webResourceRoot = ''
  [System.IO.File]::WriteAllText($temporaryPath, ($pluginOnly | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
  & python $validator $temporaryPath | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Expected plugin-only context to pass validation.' }

  $javascriptOnly = Get-Content -LiteralPath $examplePath -Raw | ConvertFrom-Json
  $javascriptOnly.workflow.enabledTaskTypes = @('javascript-webresource')
  $javascriptOnly.deployment.pluginProjectPath = ''
  [System.IO.File]::WriteAllText($temporaryPath, ($javascriptOnly | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
  & python $validator $temporaryPath | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Expected JavaScript-only context to pass validation.' }

  $invalid = Get-Content -LiteralPath $examplePath -Raw | ConvertFrom-Json
  $invalid.dataverse.environmentType = 'production'
  [System.IO.File]::WriteAllText($temporaryPath, ($invalid | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
  & python $validator $temporaryPath | Out-Null
  if ($LASTEXITCODE -eq 0) { throw 'Expected production environment to fail validation.' }

  $invalid.modelPolicy.profile = 'unknown'
  $invalid.dataverse.environmentType = 'development'
  [System.IO.File]::WriteAllText($temporaryPath, ($invalid | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
  & python $validator $temporaryPath | Out-Null
  if ($LASTEXITCODE -eq 0) { throw 'Expected unsupported model policy to fail validation.' }
  Write-Output 'Project context validator tests passed.'
} finally {
  Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
}
