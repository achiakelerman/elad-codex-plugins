param(
  [Parameter(Mandatory=$true)][string]$PluginId,
  [string]$EnvironmentUrl,
  [string]$Configuration = "Debug",
  [string]$PluginFile = ""
)

$cmd = @("pac","plugin","push","--pluginId",$PluginId,"--configuration",$Configuration)
if ($EnvironmentUrl) { $cmd += @("--environment", $EnvironmentUrl) }
if ($PluginFile) { $cmd += @("--pluginFile", $PluginFile) }
Write-Host ("Running: " + ($cmd -join ' '))
& $cmd[0] $cmd[1..($cmd.Length-1)]
