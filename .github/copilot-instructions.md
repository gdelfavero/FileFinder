# FileFinder - AI Agent Instructions

## Project Overview
PowerShell module collection for finding specific file types (Office documents, media files, password vaults). The project follows standard PowerShell module structure for PSGallery publishing.

## Architecture

### Module Structure
- **PsFindFiles/**: Production module ready for PSGallery publishing
  - `PsFindFiles.psd1`: Module manifest with metadata (GUID: 247362b2-9bcd-4b1e-8479-403817629b07)
  - `PsFindFiles.psm1`: Auto-loader that dot-sources all `.ps1` files from Public/ and Private/
  - `Public/`: Exported cmdlets (automatically exported by `.psm1` using BaseName)
  - `Private/`: Internal helpers (imported but not exported)
- **helper/**: Development/prototype scripts (gitignored, not part of module)
  - Contains standalone scripts like `PsMediaFinder.ps1` (not yet integrated into module)

### Module Loading Pattern
The `.psm1` file uses dynamic function loading:
```powershell
# Dot-sources all Public/*.ps1 and Private/*.ps1
Export-ModuleMember -Function $PublicFunctions.BaseName
```
This means:
- New public functions: Add `.ps1` file to `Public/`, it auto-exports
- New private helpers: Add `.ps1` file to `Private/`, stays internal
- **Critical**: Update `FunctionsToExport` array in `.psd1` manually when adding public functions

## Key Conventions

### Function Structure
All cmdlets follow advanced function pattern with:
- `[CmdletBinding()]` attribute for common parameters
- Comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`, `.OUTPUTS`
- Parameter validation: `[Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]`
- `begin/process/end` blocks for pipeline support
- `Get-Location` for default paths, not hardcoded
- Error handling: `ErrorAction SilentlyContinue` with try/catch

### Extension Management Pattern
Functions organize file extensions in arrays (see `Find-MsOfficeFiles.ps1`):
```powershell
$modernExtensions = @('*.docx', '*.xlsx', '*.pptx', ...)
$legacyExtensions = @('*.doc', '*.xls', '*.ppt', ...)
```
Use switch parameters (e.g., `-IncludeLegacy`) to control which sets to search.

### Search Implementation
Use `Get-ChildItem` with splatted parameters:
```powershell
$searchParams = @{
    Path = $Path
    Filter = $extension
    File = $true
    ErrorAction = 'SilentlyContinue'
}
if ($Recurse) { $searchParams['Recurse'] = $true }
Get-ChildItem @searchParams
```

### Output Formatting (PsMediaFinder Pattern)
For user-facing scripts:
- Box drawing characters for headers: `╔══════╗`
- Color-coded output by file type (Magenta=Audio, Blue=Video, Yellow=Picture, Red=Vaults)
- `-ShowDetails` switch for verbose output vs. compact list
- Helper functions for formatting: `Format-FileSizeInternal` (GB/MB/KB)
- Export options: `-ExportCSV`, `-ExportJSON` parameters

## Development Workflow

### Testing Module Changes
```powershell
# Reimport module after changes
Import-Module ./PsFindFiles/PsFindFiles.psd1 -Force

# Test with verbose output
Find-MsOfficeFiles -Path . -Recurse -Verbose
```

### Adding New Functions
1. Create `.ps1` file in `Public/` (for exported) or `Private/` (for internal)
2. Follow naming convention: `Verb-Noun` (approved verbs: `Get-Verb`)
3. **Update `FunctionsToExport` in `PsFindFiles.psd1`** - this is NOT automatic
4. Increment `ModuleVersion` in manifest for releases

### Migrating Helper Scripts to Module
The `helper/PsMediaFinder.ps1` is a candidate for module integration:
- Extract `Find-MediaFiles` function to `Public/Find-MediaFiles.ps1`
- Remove script parameter block (only function parameters)
- Remove execution logic at bottom (script-specific)
- Add to `FunctionsToExport` in manifest

## File Type Extensions Reference
When adding new file search functions, reference existing patterns:
- **Office**: Modern (`.docx`, `.xlsx`, `.pptx`) vs Legacy (`.doc`, `.xls`, `.ppt`)
- **Media**: Audio (`.mp3`, `.flac`), Video (`.mp4`, `.mkv`), Pictures (`.jpg`, `.png`)
- **Vaults**: `.kdbx`, `.1pif`, `.opvault`, `.psafe3` (password managers)

## Module Manifest Requirements
For PSGallery compatibility, ensure `.psd1` includes:
- `ModuleVersion` (semantic versioning)
- `GUID` (immutable identifier)
- `Author`, `Description`, `ProjectUri`
- `PowerShellVersion = '5.1'` (minimum)
- `Tags` for discoverability
- Explicit `FunctionsToExport`, `CmdletsToExport`, `AliasesToExport` (no wildcards)

## Testing Approach
- Test on paths with spaces: `"C:\Program Files\Test"`
- Test with `-Recurse` on large directories
- Verify pipeline input: `"C:\Docs" | Find-MsOfficeFiles`
- Check legacy format detection when applicable
