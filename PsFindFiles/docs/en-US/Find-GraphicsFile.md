---
external help file: PsFindFiles-help.xml
Module Name: PsFindFiles
online version:
schema: 2.0.0
---

# Find-GraphicsFile
## SYNOPSIS
Searches for graphics and visualization assets (2D, 3D, point cloud) in a specified directory.

## SYNTAX
```
Find-GraphicsFile [[-Path] <String>] [-GraphicsType <String>] [-Recurse] [-ExportCSV <String>] [-ExportJSON <String>] [-ShowDetails] [-ShowBanner] [<CommonParameters>]
```

## DESCRIPTION
Finds common 2D design files, 3D models, and point cloud formats with optional recursion and CSV/JSON export.

## EXAMPLES
### Example 1: Search for 2D designs
```
Find-GraphicsFile -Path "C:\Design" -GraphicsType 2D
```
Finds 2D design files under the specified path.

### Example 2: Search 3D assets without recursion
```
Find-GraphicsFile -Path "D:\Assets" -GraphicsType 3D -Recurse:$false
```
Finds 3D assets in the top-level folder only.

### Example 3: Export point clouds to CSV
```
Find-GraphicsFile -Path "E:\Scans" -GraphicsType PointCloud -ExportCSV scans.csv -ShowDetails
```
Finds point cloud files and exports a detailed CSV.

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

### -GraphicsType
Graphics category to search. Valid values: `2D`, `3D`, `PointCloud`, `All`.

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
You can pipe a path to `Find-GraphicsFile`.

## OUTPUTS
### PSCustomObject
One object per graphics file with name, path, directory, extension, size, type, and timestamps.

## NOTES
Aliases: `Find-GraphicsFiles` (legacy plural name).

## RELATED LINKS
[Find-MediaFile](Find-MediaFile.md)
[Find-MsOfficeFile](Find-MsOfficeFile.md)
