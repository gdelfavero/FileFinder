# FileFinder

A PowerShell module collection for finding specific types of files.

## PsFindFiles Module

PsFindFiles is a PowerShell module that provides cmdlets for finding various types of files on your system.

### Installation

To use this module, clone the repository and import the module:

```powershell
Import-Module ./PsFindFiles/PsFindFiles.psd1
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
│   └── Find-MsOfficeFiles.ps1
└── Private/                  # Internal helper functions
```

### Development

Functions in the `Public` folder are automatically exported by the module.
Functions in the `Private` folder are loaded but not exported (internal use only).

### License

This project is open source.