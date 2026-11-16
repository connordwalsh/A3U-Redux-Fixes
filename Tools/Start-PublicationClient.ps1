param(
    [Parameter(Mandatory=$true)][string]$SteamLibrary,
    [ValidateRange(1024,65531)][int]$Port=11002,
    [ValidatePattern('^[A-Za-z0-9_-]{1,24}$')][string]$Instance='Client1'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$game=Join-Path $SteamLibrary 'steamapps/common/Arma 3'
$profile=Join-Path $root ('.work/profiles/publication-client-'+$Instance)
if (Get-CimInstance Win32_Process | Where-Object {$_.Name -eq 'arma3server_x64.exe' -and $_.CommandLine -and $_.CommandLine.Contains($profile)}) {throw 'This client profile is already running'}
$workshop=Join-Path $SteamLibrary 'steamapps/workshop/content/107410'
$mods=@('450814997','3020755032','583496184','1128256978') | ForEach-Object {Join-Path $workshop $_}
$exe=Join-Path $game 'arma3server_x64.exe'
foreach ($required in @($exe)+$mods) {if (!(Test-Path -LiteralPath $required)) {throw "Missing input: $required"}}
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$launchArgs=@('-client','-connect=127.0.0.1',('-port='+$Port),'-noSound',('-name=A3URF_Publication_'+$Instance),
    ('"-profiles={0}"' -f $profile),('"-mod={0}"' -f ($mods -join ';')))
$process=Start-Process -FilePath $exe -ArgumentList $launchArgs -WorkingDirectory $game -WindowStyle Hidden -PassThru
$receipt=@{ProcessId=$process.Id;Profile=$profile;Port=$Port;StartedUTC=[DateTime]::UtcNow.ToString('o');Mods=$mods}
$receipt | ConvertTo-Json | Set-Content (Join-Path $profile 'launch.json') -Encoding UTF8
[pscustomobject]$receipt
