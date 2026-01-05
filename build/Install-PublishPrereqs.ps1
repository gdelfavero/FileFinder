[CmdletBinding()]
param(
    [switch]$SkipPester,
    [switch]$SkipPSScriptAnalyzer,
    [switch]$SkipPlatyPS,
    [string]$Scope = 'CurrentUser'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Install-ModuleIfMissing {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Scope,
        [switch]$Skip
    )

    if ($Skip) {
        Write-Verbose "Skipping $Name as requested"
        return
    }

    $existing = Get-Module -ListAvailable -Name $Name | Select-Object -First 1
    if ($existing) {
        Write-Verbose "$Name is already available (version $($existing.Version))"
        return
    }

    Write-Host "Installing $Name ..."
    Install-Module -Name $Name -Scope $Scope -Force -AllowClobber -ErrorAction Stop
}

# Ensure NuGet provider is present
if (-not (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq 'NuGet' })) {
    Write-Host 'Installing NuGet package provider ...'
    Install-PackageProvider -Name NuGet -Force -ErrorAction Stop
}

function Ensure-PesterV5 {
    param(
        [string]$Scope,
        [switch]$Skip,
        [Version]$MinimumVersion = [Version]'5.0.0'
    )

    if ($Skip) {
        Write-Verbose 'Skipping Pester as requested'
        return
    }

    $existing = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
    if ($existing -and $existing.Version -ge $MinimumVersion) {
        Write-Verbose "Pester already available (version $($existing.Version))"
        return
    }

    Write-Host "Installing Pester (>= $MinimumVersion) ..."
    Install-Module -Name Pester -MinimumVersion $MinimumVersion -Scope $Scope -Force -AllowClobber -ErrorAction Stop
}

# Install required modules
Install-ModuleIfMissing -Name 'PSScriptAnalyzer' -Scope $Scope -Skip:$SkipPSScriptAnalyzer
Ensure-PesterV5 -Scope $Scope -Skip:$SkipPester
Install-ModuleIfMissing -Name 'PlatyPS' -Scope $Scope -Skip:$SkipPlatyPS

Write-Host 'Prerequisite check completed.'
