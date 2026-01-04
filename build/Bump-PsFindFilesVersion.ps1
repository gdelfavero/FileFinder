[CmdletBinding(DefaultParameterSetName = 'BumpPatch')]
param(
    [Parameter(ParameterSetName = 'SetVersion')]
    [Version]$Version,

    [Parameter(ParameterSetName = 'BumpMajor')]
    [switch]$BumpMajor,

    [Parameter(ParameterSetName = 'BumpMinor')]
    [switch]$BumpMinor,

    [Parameter(ParameterSetName = 'BumpPatch')]
    [switch]$BumpPatch,

    [string]$ManifestPath = (Join-Path $PSScriptRoot '..' 'PsFindFiles' 'PsFindFiles.psd1'),
    [switch]$SkipSync,
    [switch]$SkipChangelog,
    [string]$SinceRef,
    [int]$MaxCommits = 50
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Manifest not found at $ManifestPath"
}

$manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
$currentVersion = [Version]$manifest.ModuleVersion

switch ($PSCmdlet.ParameterSetName) {
    'SetVersion' { $newVersion = $Version }
    'BumpMajor' { $newVersion = [Version]::new($currentVersion.Major + 1, 0, 0) }
    'BumpMinor' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0) }
    default     { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1) }
}

if ($newVersion -le $currentVersion) {
    throw "New version $newVersion must be greater than current version $currentVersion"
}

Update-ModuleManifest -Path $ManifestPath -ModuleVersion $newVersion.ToString()

Write-Host "Updated module version: $currentVersion -> $newVersion"

if (-not $SkipSync) {
    $syncScript = Join-Path $PSScriptRoot 'Sync-PsFindFilesVersion.ps1'
    if (-not (Test-Path -LiteralPath $syncScript)) {
        Write-Warning "Sync script not found at $syncScript; skipping version sync."
    } else {
        & $syncScript -ManifestPath $ManifestPath
    }
}

if (-not $SkipChangelog) {
    $changelogScript = Join-Path $PSScriptRoot 'Update-PsFindFilesChangelog.ps1'
    if (-not (Test-Path -LiteralPath $changelogScript)) {
        Write-Warning "Changelog script not found at $changelogScript; skipping changelog update."
    } else {
        & $changelogScript -ManifestPath $ManifestPath -SinceRef $SinceRef -MaxCommits $MaxCommits
    }
}
