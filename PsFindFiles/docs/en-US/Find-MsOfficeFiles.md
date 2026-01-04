---
external help file: PsFindFiles-help.xml
Module Name: PsFindFiles
online version:
schema: 2.0.0
---

# Find-MsOfficeFiles

## SYNOPSIS
Finds Microsoft Office files in a specified path.

## SYNTAX

```
Find-MsOfficeFiles [[-Path] <String>] [-Recurse] [-IncludeLegacy] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Find-MsOfficeFiles function searches for Microsoft Office files (Word, Excel, PowerPoint, Access, etc.)
in a specified directory and optionally in its subdirectories.
It supports both legacy and modern Office formats.

## EXAMPLES

### EXAMPLE 1
```
Find-MsOfficeFiles
Finds all modern Microsoft Office files in the current directory.
```

### EXAMPLE 2
```
Find-MsOfficeFiles -Path "C:\Documents" -Recurse
Finds all modern Microsoft Office files in C:\Documents and its subdirectories.
```

### EXAMPLE 3
```
Find-MsOfficeFiles -Path "C:\Documents" -Recurse -IncludeLegacy
Finds all Microsoft Office files (both modern and legacy formats) in C:\Documents and its subdirectories.
```

### EXAMPLE 4
```
"C:\Docs","D:\Shared" | Find-MsOfficeFiles -Recurse
Pipes multiple paths into the command and searches recursively.
```

## PARAMETERS

### -Path
The path to search for Microsoft Office files.
Defaults to the current directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Location).Path
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse
If specified, searches subdirectories recursively.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeLegacy
If specified, includes legacy Office formats (.doc, .xls, .ppt) in addition to modern formats.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies how PowerShell responds to progress updates for the command.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
Accepts pipeline input for `Path`.

## OUTPUTS

### System.IO.FileInfo
## NOTES
Version: 1.0.1
Author: gdelfavero

## RELATED LINKS
