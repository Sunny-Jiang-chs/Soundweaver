[CmdletBinding()]
param(
    [string]$Python = '',
    [string]$FfmpegRoot = 'D:\tools\ffmpeg\ffmpeg-9.0.1-essentials_build',
    [string]$Compiler = 'D:\tools\inno-setup\compiler\ISCC.exe',
    [string]$WebView2Bootstrapper = 'D:\tools\webview2\MicrosoftEdgeWebview2Setup.exe'
)

$ErrorActionPreference = 'Stop'
$setupRoot = $PSScriptRoot
$setupVersion = ([IO.File]::ReadAllText((Join-Path $setupRoot 'VERSION'))).Trim()
if ($setupVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid VERSION.' }
foreach ($setupDependency in @($Compiler, $WebView2Bootstrapper, "$FfmpegRoot\bin\ffmpeg.exe", "$FfmpegRoot\bin\ffprobe.exe", "$FfmpegRoot\LICENSE", "$FfmpegRoot\README.txt")) {
    if (-not (Test-Path -LiteralPath $setupDependency -PathType Leaf)) { throw "Missing installer dependency: $setupDependency" }
}
$setupSignature = Get-AuthenticodeSignature -LiteralPath $WebView2Bootstrapper
if ($setupSignature.Status -ne 'Valid' -or $setupSignature.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') {
    throw 'WebView2 bootstrapper must have a valid Microsoft signature.'
}
& (Join-Path $setupRoot 'build.ps1') -Mode onedir -Python $Python
if (-not $?) { throw 'Application build failed.' }
$setupApp = Join-Path $setupRoot 'dist\Soundweaver'
$setupTools = Join-Path $setupApp 'tools\ffmpeg'
New-Item -ItemType Directory -Force -Path $setupTools | Out-Null
foreach ($setupTool in @('ffmpeg', 'ffprobe')) {
    Copy-Item -LiteralPath "$FfmpegRoot\bin\$setupTool.exe" -Destination $setupTools -Force
    & (Join-Path $setupTools "$setupTool.exe") -version *> $null
    if ($LASTEXITCODE -ne 0) { throw "Bundled $setupTool could not run." }
}
Copy-Item -LiteralPath "$FfmpegRoot\LICENSE", "$FfmpegRoot\README.txt" -Destination $setupTools -Force
Copy-Item -LiteralPath (Join-Path $setupRoot 'THIRD_PARTY_NOTICES.md') -Destination $setupApp -Force
$setupWork = Join-Path $setupRoot ('tmp\setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $setupWork | Out-Null
$setupCommit = (& git -C $setupRoot rev-parse HEAD).Trim()
$setupDirty = [bool](& git -C $setupRoot status --porcelain)
& $Compiler "/DAppVersion=$setupVersion" "/DAppSource=$setupApp" "/DBootstrapper=$WebView2Bootstrapper" "/DSetupOutput=$setupWork" (Join-Path $setupRoot 'installer\Soundweaver.iss')
if ($LASTEXITCODE -ne 0) { throw 'Setup compilation failed.' }
$setupName = "Soundweaver-$setupVersion-Setup.exe"
$setupFile = Join-Path $setupWork $setupName
$setupDigest = (Get-FileHash -LiteralPath $setupFile -Algorithm SHA256).Hash.ToLowerInvariant()
$setupDist = Join-Path $setupRoot 'dist'
if (Test-Path -LiteralPath (Join-Path $setupDist $setupName)) { throw "Setup already exists; new file preserved at $setupFile" }
Copy-Item -LiteralPath $setupFile -Destination $setupDist
[IO.File]::WriteAllText((Join-Path $setupDist "$setupName.sha256"), "$setupDigest  $setupName`n", [Text.UTF8Encoding]::new($false))
$setupRecord = @{ version=$setupVersion; gitCommit=$setupCommit; dirty=$setupDirty; builtAtUtc=[DateTime]::UtcNow.ToString('o'); file=$setupName; sha256=$setupDigest; bytes=(Get-Item -LiteralPath $setupFile).Length }
[IO.File]::WriteAllText((Join-Path $setupDist "$setupName.build.json"), ($setupRecord | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
Write-Output "SETUP: $(Join-Path $setupDist $setupName)"
