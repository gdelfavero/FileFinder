[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..' 'PsFindFiles' 'PsFindFiles.psd1'),
    [string]$ChangelogPath = (Join-Path $PSScriptRoot '..' 'CHANGELOG.md'),
    [string]$SinceRef,
    [int]$MaxCommits = 50
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Manifest not found at $ManifestPath"
}

$manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
$version = $manifest.ModuleVersion
if (-not $version) {
    throw 'ModuleVersion not found in manifest.'
}

# Collect commit messages
$git = Get-Command git -ErrorAction SilentlyContinue
$commitLines = @()
if (-not $git) {
    Write-Warning 'git not found in PATH; changelog will note missing commit data.'
} else {
    $logArgs = @('log', '--pretty=format:%h %s')
    if ($SinceRef) {
        $logArgs += "$SinceRef..HEAD"
    } else {
        $logArgs += @('-n', $MaxCommits)
    }
    try {
        $commitLines = git @logArgs
    } catch {
        Write-Warning "git log failed: $_"
    }
}

if (-not $commitLines -or $commitLines.Count -eq 0) {
    $commitLines = @('No commit data available.')
}

$today = (Get-Date).ToString('yyyy-MM-dd')
$newEntry = @()
$newEntry += "## v$version - $today"
$newEntry += ''
foreach ($line in $commitLines) {
    $newEntry += "- $line"
}
$newEntry += ''

$existing = ''
if (Test-Path -LiteralPath $ChangelogPath) {
    $existing = Get-Content -LiteralPath $ChangelogPath -Raw
}

$combined = ($newEntry -join [Environment]::NewLine)
if ($existing) {
    $combined = $combined + [Environment]::NewLine + $existing
}

Set-Content -LiteralPath $ChangelogPath -Value $combined

Write-Host "Changelog updated for v$version"
