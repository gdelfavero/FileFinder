# Build / Deploy / Publish

This folder centralizes the steps and scripts for preparing and publishing `PsFindFiles` to the PowerShell Gallery.

## Prerequisites
- PowerShell 5.1 or 7.x
- NuGet provider installed (`Install-PackageProvider -Name NuGet -Force`)
- Modules: `PSScriptAnalyzer`, `Pester` (v5+), `PlatyPS`, `PowerShellGet` (latest available for your engine)
- PSGallery API key available and stored securely (do not commit it)

## Workflow (recommended)
1) Install prerequisites:
```powershell
./build/Install-PublishPrereqs.ps1 -Verbose
```
2) Bump the module version (auto-sync README and changelog):
```powershell
./build/Bump-PsFindFilesVersion.ps1 -BumpPatch -Verbose
```
Or:
```powershell
./build/Bump-PsFindFilesVersion.ps1 -BumpMinor -Verbose
```
```powershell
./build/Bump-PsFindFilesVersion.ps1 -Version 1.2.2 -Verbose
```
3) Refresh PlatyPS markdown help when parameters/examples change:
```powershell
Import-Module PlatyPS
Import-Module ./PsFindFiles/PsFindFiles.psd1 -Force
Update-MarkdownHelp -Module PsFindFiles -OutputFolder ./PsFindFiles/docs/en-US -Force
```
4) Regenerate external help (XML) from markdown:
```powershell
New-ExternalHelp -Path ./PsFindFiles/docs/en-US -OutputPath ./PsFindFiles/en-US -Force
```
5) Lint and test:
```powershell
Invoke-ScriptAnalyzer -Path ./PsFindFiles -Settings ./PSScriptAnalyzerSettings.psd1
```
```powershell
Invoke-Pester -Path ./tests
```
6) Validate manifest:
```powershell
Test-ModuleManifest ./PsFindFiles/PsFindFiles.psd1
```
7) Publish:
```powershell
./Publish-PsFindFiles.ps1 -ApiKey '<your-PSGallery-key>' -Repository PSGallery
```

## Scripts
- `Install-PublishPrereqs.ps1`: Installs required tooling modules if missing.
- `Bump-PsFindFilesVersion.ps1`: Updates the module version in the manifest (patch/minor/major or explicit value) and optionally updates README and changelog.
- `Sync-PsFindFilesVersion.ps1`: Syncs the manifest version into README placeholder `__PSFINDFILES_VERSION__`.
- `Update-PsFindFilesChangelog.ps1`: Prepends a changelog entry for the current manifest version using git commit summaries.
- `Publish-PsFindFiles.ps1`: Runs lint/tests/help regeneration/manifest validation, then publishes to PSGallery with WhatIf support.

## Notes
- Run from the repo root unless otherwise noted.
- Keep API keys out of source control; use environment variables or a secure string when invoking publish.
- Tests target `Pester` v5+.

## API key handling (SecretManagement)
Install SecretManagement and SecretStore:
```powershell
Install-Module Microsoft.PowerShell.SecretManagement -Scope CurrentUser -Force
```
```powershell
Install-Module Microsoft.PowerShell.SecretStore -Scope CurrentUser -Force
```
Register a local vault (default):
```powershell
Register-SecretVault -Name LocalSecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
```
Store your PSGallery API key:
```powershell
Set-Secret -Name GDF_PWSH_PSFILEFINDER_PUBLISH -Secret 'your-api-key'
```
Use it when publishing:
```powershell
./build/Publish-PsFindFiles.ps1 -ApiKey (Get-Secret GDF_PWSH_PSFILEFINDER_PUBLISH) -Repository PSGallery
```
