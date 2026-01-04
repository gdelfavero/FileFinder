---
external help file: PsFindFiles-help.xml
Module Name: PsFindFiles
online version:
schema: 2.0.0
---

# Find-MediaFiles

## SYNOPSIS
Searches for media files (audio, video, pictures, and vaults) in a specified directory.

## SYNTAX

```
Find-MediaFiles [[-Path] <String>] [-MediaType <String>] [-Recurse <Boolean>] [-ExportCSV <String>]
 [-ExportJSON <String>] [-ShowDetails] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Find-MediaFiles function searches for media files in a specified directory.
It supports recursive search, filtering by media type, and various output formats.
Results can be displayed with detailed information and exported to CSV or JSON formats.

## EXAMPLES

### EXAMPLE 1
```
Find-MediaFiles
Searches for all media files in the current directory and subdirectories.
```

### EXAMPLE 2
```
Find-MediaFiles -Path "C:\Users\Documents" -MediaType Audio
Searches for audio files only in the specified directory.
```

### EXAMPLE 3
```
Find-MediaFiles -Path "D:\Media" -Recurse $false
Searches for media files only in the specified directory (no subdirectories).
```

### EXAMPLE 4
```
Find-MediaFiles -Path "C:\Media" -ExportCSV "media_results.csv" -ShowDetails
Searches for all media files and exports detailed results to CSV.
```

### EXAMPLE 5
```
Find-MediaFiles -Path "C:\Users\me" -MediaType Vaults -Recurse:$false
Quick vault scan without recursion.
```

### EXAMPLE 6
```
Find-MediaFiles -Path "E:\Reports" -MediaType Picture -ExportJSON "pics.json"
Exports picture metadata to JSON for a reports folder.
```

## PARAMETERS

### -Path
The directory path to search for media files.
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

### -MediaType
The type of media to search for.
Valid values: Audio, Video, Picture, Vaults, All
Default: All

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
Search subdirectories recursively.
Default: $true

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportCSV
Export results to a CSV file at the specified path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportJSON
Export results to a JSON file at the specified path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowDetails
Display detailed information about each file (size, creation date, modification date).

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

### PSCustomObject[]
### Returns an array of custom objects containing file information.
## NOTES
Author: gdelfavero
Version: 2.0

## RELATED LINKS
