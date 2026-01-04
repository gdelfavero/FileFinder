[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..' 'PsFindFiles' 'PsFindFiles.psd1'),
    [string]$ReadmePath = (Join-Path $PSScriptRoot '..' 'README.md'),
    [string]$Placeholder = '__PSFINDFILES_VERSION__'
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

if (-not (Test-Path -LiteralPath $ReadmePath)) {
    Write-Warning "README not found at $ReadmePath; skipping README sync."
} else {
    $content = Get-Content -LiteralPath $ReadmePath -Raw
    if ($content -notlike "*${Placeholder}*") {
        Write-Warning "Placeholder $Placeholder not found in README; no replacement made."
    } else {
        $updated = $content -replace [regex]::Escape($Placeholder), [regex]::Escape($version)
        Set-Content -LiteralPath $ReadmePath -Value $updated -NoNewline
        Write-Host "README version placeholder updated to $version"
    }
}

Write-Host "Sync complete. ModuleVersion: $version"
