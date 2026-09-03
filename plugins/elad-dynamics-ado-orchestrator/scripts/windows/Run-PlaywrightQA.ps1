param(
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [string]$Grep = ""
)
Push-Location $ProjectPath
try {
  if ($Grep) {
    & npx playwright test --grep $Grep
  } else {
    & npx playwright test
  }
} finally {
  Pop-Location
}
