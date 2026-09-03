[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ContextPath,
  [Parameter(Mandatory = $true)][string]$WorkItemId,
  [string]$BranchSuffix = ''
)

$context = Get-Content -LiteralPath $ContextPath -Raw | ConvertFrom-Json
$projectPath = $context.workspace.codePath
$remote = $context.ado.baseRemote
$baseBranch = $context.ado.defaultBranch
$dirty = (& git -C $projectPath status --porcelain)
if ($dirty) { throw 'Git preflight blocked: the repository worktree is not clean.' }
& git -C $projectPath fetch $remote $baseBranch
if ($LASTEXITCODE -ne 0) { throw "Git preflight blocked: unable to fetch $remote/$baseBranch." }
$currentBranch = (& git -C $projectPath branch --show-current).Trim()
$currentHead = (& git -C $projectPath rev-parse HEAD).Trim()
$baseHead = (& git -C $projectPath rev-parse "$remote/$baseBranch").Trim()
$safeSuffix = if ($BranchSuffix) {
  '-' + ($BranchSuffix -replace '[^A-Za-z0-9-]', '-')
} else {
  '-' + (Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss')
}
$taskBranch = "orchestrator/$WorkItemId$safeSuffix"
& git -C $projectPath show-ref --verify --quiet "refs/heads/$taskBranch"
if ($LASTEXITCODE -eq 0) { throw "Git preflight blocked: task branch already exists: $taskBranch" }
& git -C $projectPath switch --create $taskBranch "$remote/$baseBranch"
if ($LASTEXITCODE -ne 0) { throw "Git preflight blocked: unable to create $taskBranch from $remote/$baseBranch." }
$report = [ordered]@{
  workItemId = $WorkItemId
  currentBranchBeforeRun = $currentBranch
  currentHeadBeforeRun = $currentHead
  baseRemote = $remote
  baseBranch = $baseBranch
  baseHead = $baseHead
  taskBranch = $taskBranch
  cleanWorktree = $true
  generatedAt = (Get-Date).ToUniversalTime().ToString('o')
}
$reportDirectory = Join-Path $projectPath $context.workspace.runArtifactsPath $WorkItemId
New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
$reportPath = Join-Path $reportDirectory 'git_preflight_report.json'
[System.IO.File]::WriteAllText($reportPath, ($report | ConvertTo-Json -Depth 6), [System.Text.UTF8Encoding]::new($false))
$report | ConvertTo-Json -Depth 6
