param([Parameter(Mandatory = $true, Position = 0)][string] $RemoteCommand)
$plink = 'C:\Program Files\PuTTY\plink.exe'
$session = if ($env:PUTTY_SESSION) { $env:PUTTY_SESSION } else { '107' }
& $plink -load $session -shareexists *> $null
if ($LASTEXITCODE -ne 0) { Write-Output 'SSH_UPSTREAM_MISSING: reconnect PuTTY.'; exit 70 }
& $plink -load $session -share -batch $RemoteCommand 2>&1 | ForEach-Object { "$_" }
$rc = $LASTEXITCODE
Write-Output "`nSCHOOL_EXIT_CODE=$rc"
exit $rc

