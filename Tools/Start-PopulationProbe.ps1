param(
    [Parameter(Mandatory=$true)][string]$SteamLibrary,
    [Parameter(Mandatory=$true)][string]$ArmaTools,
    [ValidateSet('Baseline','Fixed')][string]$Mode='Fixed',
    [switch]$NoLoopback,
    [ValidateSet('GarrisonSync','Publication','GarrisonLogic','Garrison','Population','Pricing','Market','Negative','Markers','Parking','HCEmpty','HCLeader','HCLogged','HCMarta','HCDeferred','SmartQuiet','SmartLogged','SmartCalls','AddonActivation','CrateStock','CrateEmpty','CrateRuntime','CratePlacedStock','CratePlacedEmpty','CrateGuards')][string]$Suite='Population',
    [ValidateSet('chernarusredux','Altis')][string]$World='chernarusredux',
    [ValidateRange(1024,65531)][int]$Port=5102
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$game=Join-Path $SteamLibrary 'steamapps/common/Arma 3'
$profile=Join-Path $root ('.work/profiles/'+$Suite.ToLowerInvariant()+'-'+$Mode)
if ($World -ne 'chernarusredux') {$profile+='-'+$World}
if (Get-CimInstance Win32_Process | Where-Object {$_.Name -eq 'arma3server_x64.exe' -and $_.CommandLine -and $_.CommandLine.Contains($profile)}) {throw 'This probe is already running.'}
$missionName='A3URF_'+$Suite+'_'+$Mode+'.'+$World
$stage=Join-Path $root ('.work/probe-stage/'+[guid]::NewGuid().ToString('N'))
$probeSource=Join-Path $root ('tests/'+$Suite.ToLowerInvariant()+'.chernarusredux')
foreach ($required in @('mission.sqm','description.ext','initServer.sqf')) {
    if (!(Test-Path -LiteralPath (Join-Path $probeSource $required))) {throw "Missing probe source: $required"}
}
if ($Suite -in @('Markers','Parking') -and !(Test-Path -LiteralPath (Join-Path $probeSource 'markerData.sqf'))) {throw 'Missing extracted marker data'}
$mission=Join-Path $stage $missionName;$packed=Join-Path $stage 'packed'
New-Item -ItemType Directory -Path $mission,$packed,$profile -Force | Out-Null
Copy-Item (Join-Path $probeSource '*') -Destination $mission
foreach ($file in @('mission.sqm','description.ext')) {
    & (Join-Path $ArmaTools 'CfgConvert/CfgConvert.exe') -bin -dst (Join-Path $stage ($file+'.bin')) (Join-Path $mission $file)
    if ($LASTEXITCODE -ne 0) {throw "Mission validation failed: $file"}
}
& (Join-Path $ArmaTools 'FileBank/FileBank.exe') -property ('prefix='+$missionName) -dst $packed $mission
if ($LASTEXITCODE -ne 0) {throw 'Mission packing failed'}
$target=Join-Path $game ('MPMissions/'+$missionName+'.pbo')
$receiptPath=Join-Path $profile 'mission-install.json'
if (Test-Path -LiteralPath $target) {
    if (!(Test-Path -LiteralPath $receiptPath)) {throw 'Preserve existing unmanaged mission'}
    $old=Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json
    if ($old.Path -ne $target -or $old.SHA256 -ne (Get-FileHash $target).Hash) {throw 'Existing mission changed; preserve it'}
}
Copy-Item -LiteralPath (Join-Path $packed ($missionName+'.pbo')) -Destination $target -Force
@{Path=$target;SHA256=(Get-FileHash $target).Hash} | ConvertTo-Json | Set-Content $receiptPath -Encoding UTF8
$workshop=Join-Path $SteamLibrary 'steamapps/workshop/content/107410'
$mods=@('450814997','3020755032','583496184','1128256978') | ForEach-Object {Join-Path $workshop $_}
if ($Mode -eq 'Fixed') {$mods+=Join-Path $root '.work/build/@A3U_Redux_Fixes'}
foreach ($mod in $mods) {if (!(Test-Path -LiteralPath $mod)) {throw "Missing test mod: $mod"}}
$config=Join-Path $profile 'server.cfg'
@"
hostname="Redux population regression";
$(if ($Suite -in @('Publication','GarrisonSync')) {'logFile="publication-console.log";'})
maxPlayers=$(if ($Suite -in @('Publication','GarrisonSync')) {2} else {1});loopback=$(if ($NoLoopback) {0} else {1});upnp=0;persistent=1;
$(if ($Suite -in @('Publication','GarrisonSync')) {'headlessClients[]={"127.0.0.1","127.0.0.2"};localClient[]={"127.0.0.1","127.0.0.2"};BattlEye=0;'})
class Missions {class Probe {template="$missionName";difficulty="Regular";};};
"@ | Set-Content $config -Encoding ASCII
$launchArgs=@('-autoInit','-noSound','-ip=127.0.0.1',('-port='+$Port),('-name=A3URF_Population_'+$Mode),
    ('"-profiles={0}"' -f $profile),('"-config={0}"' -f $config),('"-mod={0}"' -f ($mods -join ';')))
$process=Start-Process -FilePath (Join-Path $game 'arma3server_x64.exe') -ArgumentList $launchArgs -WorkingDirectory $game -WindowStyle Hidden -PassThru
$receipt=@{NoLoopback=[bool]$NoLoopback;ProcessId=$process.Id;Mode=$Mode;Profile=$profile;StartedUTC=[DateTime]::UtcNow.ToString('o');MissionSHA256=(Get-FileHash $target).Hash}
$receipt | ConvertTo-Json | Set-Content (Join-Path $profile 'launch.json') -Encoding UTF8
[pscustomobject]$receipt
