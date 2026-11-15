param([Parameter(Mandatory=$true)][string]$ArmaTools)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$output=Join-Path $root '.work/build/@A3U_Redux_Fixes'
if (Get-CimInstance Win32_Process | Where-Object {$_.Name -in @('arma3server_x64.exe','arma3_x64.exe') -and $_.CommandLine -and $_.CommandLine.Contains($output)}) {throw 'Fix addon is in use.'}
$stage=Join-Path $root ('.work/build-stage/'+[guid]::NewGuid().ToString('N'))
$addon=Join-Path $stage 'a3urf_core';$packed=Join-Path $stage 'packed'
New-Item -ItemType Directory -Path $addon,$packed,(Join-Path $output 'addons') -Force | Out-Null
$source=Join-Path $root 'ReduxFixes/addons/core'
Copy-Item -LiteralPath (Join-Path $source 'fn_getCityData.sqf') -Destination $addon
& (Join-Path $ArmaTools 'CfgConvert/CfgConvert.exe') -bin -dst (Join-Path $addon 'config.bin') (Join-Path $source 'config.cpp')
if ($LASTEXITCODE -ne 0) {throw 'Configuration conversion failed'}
& (Join-Path $ArmaTools 'FileBank/FileBank.exe') -property 'prefix=x\a3urf\addons\core' -dst $packed $addon
if ($LASTEXITCODE -ne 0) {throw 'Addon packing failed'}
Copy-Item -LiteralPath (Join-Path $packed 'a3urf_core.pbo') -Destination (Join-Path $output 'addons') -Force
Copy-Item -LiteralPath (Join-Path $root 'ReduxFixes/mod.cpp') -Destination $output -Force
$inputs=@(Get-ChildItem (Join-Path $root 'ReduxFixes') -Recurse -File | ForEach-Object {
    @{Path=[IO.Path]::GetRelativePath($root,$_.FullName);SHA256=(Get-FileHash $_.FullName).Hash}
})
$manifest=@{BuiltUTC=[DateTime]::UtcNow.ToString('o');Inputs=$inputs;PBO=(Get-FileHash (Join-Path $output 'addons/a3urf_core.pbo')).Hash}
$manifest | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $output 'build-manifest.json') -Encoding UTF8
[pscustomobject]@{ModDirectory=$output;SHA256=$manifest.PBO}
