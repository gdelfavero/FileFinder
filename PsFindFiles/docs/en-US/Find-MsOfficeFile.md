---
external help file: PsFindFiles-help.xml
Module Name: PsFindFiles
online version:
schema: 2.0.0
---

# Find-MsOfficeFile
## SYNOPSIS
Finds Microsoft Office files in a specified path.

## SYNTAX
```
Find-MsOfficeFile [-Path <String>] [-Recurse] [-IncludeLegacy] [<CommonParameters>]
```

## DESCRIPTION
Searches for Microsoft Office files (Word, Excel, PowerPoint, Access, etc.) in a target directory, optionally recursing into subdirectories. Supports modern formats by default and can include legacy formats when requested.

## EXAMPLES
### Example 1: Modern formats in current directory
```
Find-MsOfficeFile
```
Finds all modern Office files in the current directory.

### Example 2: Recurse into subdirectories
```
Find-MsOfficeFile -Path "C:\Documents" -Recurse
```
Finds modern Office files in the specified path and its subdirectories.

### Example 3: Include legacy formats
```
Find-MsOfficeFile -Path "C:\Documents" -Recurse -IncludeLegacy
```
Finds both modern and legacy Office formats.

## PARAMETERS
### -IncludeLegacy
Include legacy Office formats (.doc, .xls, .ppt, .mdb) in addition to modern formats.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Directory to search. Accepts pipeline input. Defaults to the current directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 0
Default value: (Get-Location).Path
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse
Search subdirectories recursively.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS
### System.String
You can pipe a path to `Find-MsOfficeFile`.

## OUTPUTS
### System.IO.FileInfo
One object per matching Office file.

## NOTES
Aliases: `Find-MsOfficeFiles` (legacy plural name).

## RELATED LINKS
[Find-MediaFile](Find-MediaFile.md)
