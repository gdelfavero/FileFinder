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

### EXAMPLE 1
```
Find-GraphicsFile -Path "C:\Design" -GraphicsType 2D
```
Finds 2D design files under the specified path.

### EXAMPLE 2
```
Find-GraphicsFile -Path "D:\Assets" -GraphicsType 3D -Recurse:$false
```
Finds 3D assets in the top-level folder only.

### EXAMPLE 3
```
Find-GraphicsFile -Path "E:\Scans" -GraphicsType PointCloud -ExportCSV scans.csv -ShowDetails
```
Finds point cloud files and exports a detailed CSV.

## PARAMETERS

### -ExportCSV
Path to write a CSV export of the results.
```
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
Path to write a JSON export of the results.
```
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GraphicsType
Graphics category to search. Valid values: 2D, 3D, PointCloud, All.
```
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Directory to search. Defaults to the current directory.
```
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 0
Default value: (Get-Location).Path
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse
Search subdirectories.
```
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowBanner
Show the informational banner/header output.
```
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowDetails
Emit per-file detail lines in the informational output.
```
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS
System.String

## OUTPUTS
PSCustomObject

## NOTES
Author: gdelfavero

## RELATED LINKS
Find-MediaFile
Find-MsOfficeFile
