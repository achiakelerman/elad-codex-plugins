[CmdletBinding()]
param(
  [string]$RepositoryPath = (Split-Path -Parent $PSScriptRoot)
)

$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) "elad-git-preflight-$([guid]::NewGuid())"
$remotePath = Join-Path $temporaryRoot 'origin.git'
$workPath = Join-Path $temporaryRoot 'work'
$pluginPath = Join-Path $RepositoryPath 'plugins\elad-dynamics-ado-orchestrator'
$preflightScript = Join-Path $pluginPath 'scripts\windows\Start-GitPreflight.ps1'
$contextTemplate = Join-Path $pluginPath 'examples\project-context.example.json'
try {
  New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
  & git init --bare $remotePath | Out-Null
  & git init --initial-branch master $workPath | Out-Null
  & git -C $workPath config user.name 'ELAD Test'
  & git -C $workPath config user.email 'test@example.invalid'
  [System.IO.File]::WriteAllText((Join-Path $workPath 'README.md'), "test`n", [System.Text.UTF8Encoding]::new($false))
  [System.IO.File]::WriteAllText((Join-Path $workPath '.gitignore'), ".elad/`n", [System.Text.UTF8Encoding]::new($false))
  & git -C $workPath add README.md .gitignore
  & git -C $workPath commit -m 'Initial test commit' | Out-Null
  & git -C $workPath remote add origin $remotePath
  & git -C $workPath push --set-upstream origin master | Out-Null

  $context = Get-Content -LiteralPath $contextTemplate -Raw | ConvertFrom-Json
  $context.workspace.codePath = $workPath
  $context.workspace.runArtifactsPath = '.elad/orchestrator-runs'
  $context.ado.baseRemote = 'origin'
  $context.ado.defaultBranch = 'master'
  $contextPath = Join-Path $workPath '.elad/project-context.json'
  New-Item -ItemType Directory -Path (Split-Path -Parent $contextPath) -Force | Out-Null
  [System.IO.File]::WriteAllText($contextPath, ($context | ConvertTo-Json -Depth 10), [System.Text.UTF8Encoding]::new($false))

  & $preflightScript -ContextPath $contextPath -WorkItemId '100' | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Expected clean Git preflight to pass.' }
  $branch = (& git -C $workPath branch --show-current).Trim()
  if ($branch -notmatch '^orchestrator/100-') { throw "Unexpected task branch: $branch" }

  [System.IO.File]::WriteAllText((Join-Path $workPath 'dirty.txt'), "dirty`n", [System.Text.UTF8Encoding]::new($false))
  $blocked = $false
  try { & $preflightScript -ContextPath $contextPath -WorkItemId '101' | Out-Null } catch { $blocked = $true }
  if (-not $blocked) { throw 'Expected dirty Git preflight to block.' }
  Write-Output 'Git preflight tests passed.'
} finally {
  if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
}
