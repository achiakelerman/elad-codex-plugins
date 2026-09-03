[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ContextPath,
  [Parameter(Mandatory = $true)][string]$WorkItemId
)

$context = Get-Content -LiteralPath $ContextPath -Raw | ConvertFrom-Json
$projectPath = $context.workspace.codePath
$commands = @($context.deployment.localValidationCommands)
if ($commands.Count -eq 0) { throw 'Local validation is required before cloud operations. Configure deployment.localValidationCommands.' }
$results = foreach ($command in $commands) {
  Push-Location $projectPath
  try {
    Invoke-Expression $command
    [pscustomobject]@{ command = $command; exitCode = $LASTEXITCODE; passed = ($LASTEXITCODE -eq 0) }
  } finally {
    Pop-Location
  }
}
$report = [ordered]@{
  workItemId = $WorkItemId
  passed = (($results | Where-Object { -not $_.passed }).Count -eq 0)
  results = $results
  generatedAt = (Get-Date).ToUniversalTime().ToString('o')
}
$reportDirectory = Join-Path $projectPath $context.workspace.runArtifactsPath $WorkItemId
New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
$reportPath = Join-Path $reportDirectory 'local_validation_report.json'
[System.IO.File]::WriteAllText($reportPath, ($report | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
$report | ConvertTo-Json -Depth 8
if (-not $report.passed) { exit 1 }
