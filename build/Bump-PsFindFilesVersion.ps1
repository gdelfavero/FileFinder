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

function Format-PsFindFilesManifest {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $formatter = Get-Command Invoke-Formatter -ErrorAction SilentlyContinue
    if (-not $formatter) {
        Write-Warning 'Invoke-Formatter not found; manifest formatting skipped.'
        return
    }

    $settingsPath = Join-Path $PSScriptRoot '..' 'PSScriptAnalyzerSettings.psd1'
    if (-not (Test-Path -LiteralPath $settingsPath)) {
        Write-Warning "Formatter settings not found at $settingsPath; manifest formatting skipped."
        return
    }

    try {
        $raw = Get-Content -LiteralPath $Path -Raw
        $formatted = Invoke-Formatter -ScriptDefinition $raw -Settings $settingsPath
        Set-Content -LiteralPath $Path -Value $formatted
        Write-Host 'Manifest formatted for consistent indentation.'
    } catch {
        Write-Warning "Manifest formatting failed: $_"
    }
}

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

Format-PsFindFilesManifest -Path $ManifestPath

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
