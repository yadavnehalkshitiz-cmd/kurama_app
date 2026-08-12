$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$forbidden = @(
    '.env',
    'cookies.txt',
    'key.properties',
    'kuramabot-release.jks',
    'user_configs.json',
    'ffmpeg.exe'
)
$found = Get-ChildItem -LiteralPath $repoRoot -Recurse -File |
    Where-Object { '.git' -notin $_.FullName.Split([IO.Path]::DirectorySeparatorChar) -and $_.Name -in $forbidden }
if ($found) {
    throw "Forbidden runtime files found: $($found.FullName -join ', ')"
}
$tracked = git -C $repoRoot ls-files
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to enumerate tracked repository files.'
}
$badTracked = $tracked | Where-Object {
    $_ -match '(^|/)(\.idea|downloads|cookies|saved_videos|temp_mobile)/|(^|/)\.env$|key\.properties$|\.(jks|keystore)$'
}
if ($badTracked) {
    throw "Forbidden tracked paths found: $($badTracked -join ', ')"
}
Write-Output 'Repository boundary verified.'
