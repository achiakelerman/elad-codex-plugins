[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ProjectPath,
  [string]$TemplatePath = (Join-Path $PSScriptRoot '..\..\config\project-context.template.json'),
  [switch]$Force
)

$resolvedProjectPath = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
$contextDirectory = Join-Path $resolvedProjectPath '.elad'
$contextPath = Join-Path $contextDirectory 'project-context.json'
if ((Test-Path -LiteralPath $contextPath) -and -not $Force) {
  throw "Project context already exists: $contextPath. Use -Force only when replacing it intentionally."
}

function Read-RequiredValue([string]$Prompt, [string]$Default = '') {
  $suffix = if ($Default) { " [$Default]" } else { '' }
  do { $value = Read-Host "$Prompt$suffix" } while (-not $value -and -not $Default)
  if (-not $value) { return $Default }
  return $value
}

$context = Get-Content -LiteralPath $TemplatePath -Raw | ConvertFrom-Json
$context.projectName = Read-RequiredValue 'Project name'
$context.workspace.codePath = $resolvedProjectPath
$remoteUrl = (& git -C $resolvedProjectPath remote get-url origin 2>$null)
$context.workspace.githubRemoteUrl = Read-RequiredValue 'GitHub remote URL' $remoteUrl
$context.ado.organizationUrl = Read-RequiredValue 'Azure DevOps organization URL'
$context.ado.project = Read-RequiredValue 'Azure DevOps project'
$context.ado.repository = Read-RequiredValue 'Azure DevOps repository'
$context.ado.defaultBranch = Read-RequiredValue 'Base branch' 'master'
$context.ado.triggerTag = Read-RequiredValue 'Azure DevOps trigger tag'
$context.dataverse.environmentUrl = Read-RequiredValue 'Dataverse DEV environment URL'
$context.dataverse.solutionUniqueName = Read-RequiredValue 'Dataverse solution unique name'
$context.dataverse.publisherPrefix = Read-RequiredValue 'Dataverse publisher prefix'
$context.qa.mode = Read-RequiredValue 'QA mode (playwright or manual)' 'playwright'
$context.qa.baseAppUrl = Read-RequiredValue 'Dynamics app URL'
$context.qa.playwrightProjectPath = Read-Host 'Playwright project path (optional)'
$taskTypes = Read-RequiredValue 'Enabled task types (comma-separated: plugin-csharp,javascript-webresource,configuration,mixed)'
$context.workflow.enabledTaskTypes = @($taskTypes -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$context.deployment.pluginProjectPath = Read-Host 'Plugin project path (required for plugin-csharp or mixed)'
$context.deployment.webResourceRoot = Read-Host 'Web resource root (required for javascript-webresource or mixed)'
$context.deployment.solutionZipPath = Read-Host 'Solution ZIP path (optional)'
$context.modelPolicy.profile = Read-RequiredValue 'Model policy (balanced, economy, quality)' 'balanced'

New-Item -ItemType Directory -Path $contextDirectory -Force | Out-Null
[System.IO.File]::WriteAllText($contextPath, ($context | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))
$gitDirectory = (& git -C $resolvedProjectPath rev-parse --git-dir 2>$null)
if ($LASTEXITCODE -eq 0) {
  $excludePath = Join-Path $resolvedProjectPath $gitDirectory.Trim()
  $excludePath = Join-Path $excludePath 'info\exclude'
  $excludeEntries = if (Test-Path -LiteralPath $excludePath) { Get-Content -LiteralPath $excludePath } else { @() }
  if ($excludeEntries -notcontains '.elad/') {
    Add-Content -LiteralPath $excludePath -Value '.elad/' -Encoding utf8
  }
}
$setupReportPath = Join-Path $contextDirectory 'orchestrator-runs\project_setup_report.json'
New-Item -ItemType Directory -Path (Split-Path -Parent $setupReportPath) -Force | Out-Null
$setupReport = [ordered]@{
  status = 'setup-required'
  projectName = $context.projectName
  contextPath = $contextPath
  credentialsStored = $false
  nextStep = 'Run context validation and capability preflight.'
  generatedAt = (Get-Date).ToUniversalTime().ToString('o')
}
[System.IO.File]::WriteAllText($setupReportPath, ($setupReport | ConvertTo-Json -Depth 6), [System.Text.UTF8Encoding]::new($false))
Write-Host "Created $contextPath"
