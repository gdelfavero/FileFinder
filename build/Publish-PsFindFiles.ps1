[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey,

    [string]$Repository = 'PSGallery',

    [switch]$SkipPester,
    [switch]$SkipPlatyPS,
    [switch]$SkipScriptAnalyzer,
    [switch]$SkipHelp,

    [string]$ManifestPath = (Join-Path $PSScriptRoot '..' 'PsFindFiles' 'PsFindFiles.psd1'),
    [string]$ModulePath = (Join-Path $PSScriptRoot '..' 'PsFindFiles'),
    [string]$AnalyzerSettings = (Join-Path $PSScriptRoot '..' 'PSScriptAnalyzerSettings.psd1'),
    [string]$TestsPath = (Join-Path $PSScriptRoot '..' 'tests'),
    [string]$DocsPath = (Join-Path $PSScriptRoot '..' 'PsFindFiles' 'docs' 'en-US'),
    [string]$ExternalHelpPath = (Join-Path $PSScriptRoot '..' 'PsFindFiles' 'en-US')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-ModuleAvailable {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [switch]$Skip
    )
    if ($Skip) { return }
    if (-not (Get-Module -ListAvailable -Name $Name | Select-Object -First 1)) {
        throw "$Name is required. Install it first (see build/README.md)."
    }
}

Write-Host "Publishing PsFindFiles to $Repository (WhatIf=$($WhatIfPreference -eq $true))"

Assert-ModuleAvailable -Name 'PSScriptAnalyzer' -Skip:$SkipScriptAnalyzer
Assert-ModuleAvailable -Name 'Pester' -Skip:$SkipPester
Assert-ModuleAvailable -Name 'PlatyPS' -Skip:$SkipPlatyPS -Skip:$SkipHelp

if (-not $SkipScriptAnalyzer) {
    Write-Host 'Running PSScriptAnalyzer...'
    Invoke-ScriptAnalyzer -Path $ModulePath -Settings $AnalyzerSettings
}

if (-not $SkipPester) {
    Write-Host 'Running Pester tests...'
    Invoke-Pester -Path $TestsPath
}

if (-not $SkipHelp) {
    Write-Host 'Regenerating external help...'
    Import-Module PlatyPS -ErrorAction Stop
    if (-not (Test-Path -LiteralPath $DocsPath)) {
        throw "Docs path not found: $DocsPath"
    }
    New-ExternalHelp -Path $DocsPath -OutputPath $ExternalHelpPath -Force
}

Write-Host 'Validating module manifest...'
Test-ModuleManifest -Path $ManifestPath | Out-Null

if ($PSCmdlet.ShouldProcess("Repository $Repository", 'Publish PsFindFiles')) {
    Write-Host 'Publishing module...'
    Publish-Module -Path $ModulePath -Repository $Repository -NuGetApiKey $ApiKey -Verbose -WhatIf:$WhatIfPreference
    Write-Host 'Publish step completed.'
}
