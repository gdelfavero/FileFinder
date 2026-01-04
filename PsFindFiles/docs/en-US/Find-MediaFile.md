---
external help file: PsFindFiles-help.xml
Module Name: PsFindFiles
online version:
schema: 2.0.0
---

# Find-MediaFile
## SYNOPSIS
Searches for media files (audio, video, pictures, and vaults) in a specified directory.

## SYNTAX
```
Find-MediaFile [-Path <String>] [-MediaType <String>] [-Recurse] [-ExportCSV <String>] [-ExportJSON <String>] [-ShowDetails] [-ShowBanner] [<CommonParameters>]
```

## DESCRIPTION
Finds media files in the target path with optional recursion, filtering by media type, and CSV/JSON export. The command returns file metadata and can emit an informational summary or detailed file list.

## EXAMPLES
### Example 1: Search current directory
```
Find-MediaFile
```
Searches for all supported media files in the current directory and subdirectories.

### Example 2: Audio only
```
Find-MediaFile -Path "C:\Users\Documents" -MediaType Audio
```
Searches for audio files in the specified directory and subdirectories.

### Example 3: Disable recursion
```
Find-MediaFile -Path "D:\Media" -Recurse:$false
```
Searches only the specified directory (no subdirectories).

### Example 4: Export results
```
Find-MediaFile -Path "C:\Media" -ExportCSV "media_results.csv" -ShowDetails
```
Exports detailed results to CSV.

## PARAMETERS
### -ExportCSV
Path to write a CSV export of the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportJSON
Path to write a JSON export of the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MediaType
Media type filter. Valid values: `Audio`, `Video`, `Picture`, `Vaults`, `All`.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: All
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
Search subdirectories. Defaults to on.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowBanner
Show the informational banner/header output.

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

### -ShowDetails
Emit per-file detail lines in the informational output.

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
You can pipe a path to `Find-MediaFile`.

## OUTPUTS
### PSCustomObject
One object per file with name, path, directory, extension, type, size, and timestamps.

## NOTES
Aliases: `Find-MediaFiles` (legacy plural name).

## RELATED LINKS
[Find-MsOfficeFile](Find-MsOfficeFile.md)
