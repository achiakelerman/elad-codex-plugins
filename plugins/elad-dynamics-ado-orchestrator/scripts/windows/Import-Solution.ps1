param(
  [Parameter(Mandatory=$true)][string]$EnvironmentUrl,
  [Parameter(Mandatory=$true)][string]$Path
)
& pac solution import --environment $EnvironmentUrl --path $Path
& pac solution publish --environment $EnvironmentUrl
