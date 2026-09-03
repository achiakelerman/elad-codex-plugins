[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ContextPath
)

$context = Get-Content -LiteralPath $ContextPath -Raw | ConvertFrom-Json
$requiredCommands = @('git', 'node', 'npx', 'dotnet', 'pac')
$commands = foreach ($command in $requiredCommands) {
  [pscustomobject]@{ name = $command; available = [bool](Get-Command $command -ErrorAction SilentlyContinue) }
}
$mcpPath = Join-Path $PSScriptRoot '..\..\.mcp.json'
$mcpConfig = Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json
$environmentVariables = @('AZDO_ORG_SERVICE_URL', 'AZDO_PAT', 'AZDO_DEFAULT_PROJECT', 'DATAVERSE_URL', 'DATAVERSE_TENANT_ID') |
  ForEach-Object { [pscustomobject]@{ name = $_; configured = -not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($_)) } }
$taskTypes = @($context.workflow.enabledTaskTypes)
$skillRoot = Join-Path $PSScriptRoot '..\..\skills\elad-dynamics-ado-operator\references\agents'
$requiredSpecialists = @('orchestrator-agent.md', 'ado-intake-agent.md', 'task-classifier-agent.md', 'code-context-agent.md', 'deployment-agent.md', 'qa-agent.md', 'ado-update-agent.md')
if ($taskTypes -contains 'plugin-csharp' -or $taskTypes -contains 'mixed') { $requiredSpecialists += 'plugin-specialist-agent.md' }
if ($taskTypes -contains 'javascript-webresource' -or $taskTypes -contains 'mixed') { $requiredSpecialists += 'javascript-specialist-agent.md' }
if ($taskTypes -contains 'configuration' -or $taskTypes -contains 'mixed') { $requiredSpecialists += 'config-specialist-agent.md' }
$specialistPrompts = $requiredSpecialists | Sort-Object -Unique | ForEach-Object {
  [pscustomobject]@{ name = $_; available = Test-Path -LiteralPath (Join-Path $skillRoot $_) }
}
$mcpConfigured = @($mcpConfig.mcpServers.PSObject.Properties.Name | Sort-Object)
$requiredMcpServers = @('azure-devops', 'dataverse')
$report = [ordered]@{
  generatedAt = (Get-Date).ToUniversalTime().ToString('o')
  commands = $commands
  mcpServersDeclared = $mcpConfigured
  environmentVariables = $environmentVariables
  activeTaskTypes = $taskTypes
  specialistPrompts = $specialistPrompts
  skillVerification = 'The active Codex task must load only these available prompts for the selected task type.'
  ready = (($commands | Where-Object { -not $_.available }).Count -eq 0) -and
    (($environmentVariables | Where-Object { -not $_.configured }).Count -eq 0) -and
    (($specialistPrompts | Where-Object { -not $_.available }).Count -eq 0) -and
    (@(Compare-Object -ReferenceObject $requiredMcpServers -DifferenceObject $mcpConfigured).Count -eq 0)
}
$reportDirectory = Join-Path $context.workspace.codePath $context.workspace.runArtifactsPath
New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
$reportPath = Join-Path $reportDirectory 'capability_report.json'
[System.IO.File]::WriteAllText($reportPath, ($report | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
$report | ConvertTo-Json -Depth 8
if (-not $report.ready) { exit 1 }
