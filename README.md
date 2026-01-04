# FileFinder

A PowerShell module collection for finding specific types of files.

Current module version: 1\.1\.0

## PsFindFiles Module

PsFindFiles is a PowerShell module that provides cmdlets for finding various types of files on your system. It supports both PowerShell 7.x (Core) and Windows PowerShell 5.1 (Desktop).

### Functions Overview

- `Find-MsOfficeFiles`: Locate Microsoft Office files (modern + optional legacy) with optional recursion.
- `Find-MediaFiles`: Locate media (audio/video/picture) and vault file types, with optional exports and detailed display.

### Installation

From the repository:

```powershell
Import-Module ./PsFindFiles/PsFindFiles.psd1 -Force
```

From PowerShell Gallery (after publishing, PowerShell 5.1+ / 7+):

```powershell
Install-Module PsFindFiles
Import-Module PsFindFiles -Force
```

### Available Functions

#### Find-MsOfficeFiles

Finds Microsoft Office files in a specified path.

**Parameters:**
- `Path` - The path to search for Microsoft Office files (defaults to current directory)
- `Recurse` - Search subdirectories recursively
- `IncludeLegacy` - Include legacy Office formats (.doc, .xls, .ppt)

**Examples:**

```powershell
# Find modern Office files in current directory
Find-MsOfficeFiles

# Find Office files recursively in a specific path
Find-MsOfficeFiles -Path "C:\Documents" -Recurse

# Find both modern and legacy Office files
Find-MsOfficeFiles -Path "C:\Documents" -Recurse -IncludeLegacy

# Pipe paths in and search
"C:\Docs","D:\Shared" | Find-MsOfficeFiles -Recurse
```

#### Find-MediaFiles

Searches for media, picture, audio, video, and vault files.

**Parameters:**
- `Path` - The path to search (defaults to current directory)
- `MediaType` - One of Audio, Video, Picture, Vaults, All (default: All)
- `Recurse` - Search subdirectories (default: `$true`)
- `ExportCSV` - Export results to CSV
- `ExportJSON` - Export results to JSON
- `ShowDetails` - Show detailed output per file

**Examples:**

```powershell
# Find all media files recursively
Find-MediaFiles -Path "C:\Media"

# Only audio, no recursion
Find-MediaFiles -Path "C:\Media" -MediaType Audio -Recurse:$false

# Export video results to CSV with details
Find-MediaFiles -Path "D:\Media" -MediaType Video -ExportCSV "videos.csv" -ShowDetails

# Quick vault scan without recursion
Find-MediaFiles -Path "C:\Users\me" -MediaType Vaults -Recurse:$false

# JSON export of pictures for a reports folder
Find-MediaFiles -Path "E:\Reports" -MediaType Picture -ExportJSON "pics.json"

# Minimal: current directory, default filters
Find-MediaFiles
```

**Supported File Types:**

Modern formats (Office 2007+):
- Word: .docx, .docm, .dotx, .dotm
- Excel: .xlsx, .xlsm, .xltx, .xltm, .xlsb
- PowerPoint: .pptx, .pptm, .potx, .potm, .ppsx, .ppsm
- Access: .accdb, .accde

Legacy formats (Office 97-2003):
- Word: .doc, .dot
- Excel: .xls, .xlt
- PowerPoint: .ppt, .pot, .pps
- Access: .mdb

### Module Structure

The module follows PowerShell best practices for PSGallery publishing:

```
PsFindFiles/
├── PsFindFiles.psd1          # Module manifest
├── PsFindFiles.psm1          # Module loader
├── Public/                   # Exported functions
│   ├── Find-MsOfficeFiles.ps1
│   └── Find-MediaFiles.ps1
└── Private/                  # Internal helper functions
	└── Format-FileSize.ps1
```

### Development

Functions in the `Public` folder are automatically exported by the module.
Functions in the `Private` folder are loaded but not exported (internal use only).

### Testing & Linting

- Tests (Pester 3.4.x): `Invoke-Pester -Path ./tests`
- Lint (PSScriptAnalyzer): `Invoke-ScriptAnalyzer -Path ./PsFindFiles -Settings ./PSScriptAnalyzerSettings.psd1`
- Reimport after changes: `Import-Module ./PsFindFiles/PsFindFiles.psd1 -Force`

### Help (PlatyPS)

- Generate markdown help stubs: `Import-Module PlatyPS; New-MarkdownHelp -Module PsFindFiles -OutputFolder ./PsFindFiles/docs/en-US -WithModulePage -Force`
- Regenerate external help (MAML): `Import-Module PlatyPS; New-ExternalHelp -Path ./PsFindFiles/docs/en-US -OutputPath ./PsFindFiles/en-US -Force`

### License

This project is open source under the MIT License (see `LICENSE`).