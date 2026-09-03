param(
  [Parameter(Mandatory=$true)][string]$EnvironmentUrl,
  [Parameter(Mandatory=$true)][string]$WebResourcePath,
  [string]$SolutionUniqueName = ""
)

Write-Host "Update the target web resource file in source control first."
if ($SolutionUniqueName) {
  Write-Host "Publishing customizations for solution $SolutionUniqueName"
}
& pac solution publish --environment $EnvironmentUrl
