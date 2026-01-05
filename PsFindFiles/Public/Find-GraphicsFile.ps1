function Find-GraphicsFile {
    <#
    .SYNOPSIS
        Searches for graphics and visualization assets (2D, 3D, point cloud) in a specified directory.

    .DESCRIPTION
        The Find-GraphicsFile function scans a target directory for common 2D design files, 3D assets, and
        point cloud formats. It supports recursion, type filtering, and optional CSV/JSON export with
        summary or detailed output.

    .PARAMETER Path
        Directory path to search. Defaults to the current directory.

    .PARAMETER GraphicsType
        Graphics category to filter: 2D, 3D, PointCloud, or All. Defaults to All.

    .PARAMETER Recurse
        Search subdirectories. Defaults to on.

    .PARAMETER ExportCSV
        Write results to a CSV file at the provided path.

    .PARAMETER ExportJSON
        Write results to a JSON file at the provided path.

    .PARAMETER ShowDetails
        Emit a detailed per-file listing in the informational output stream.

    .PARAMETER ShowBanner
        Show a short banner header before search output.

    .EXAMPLE
        Find-GraphicsFile -Path "C:\Design" -GraphicsType 2D
        Finds 2D design files under C:\Design.

    .EXAMPLE
        Find-GraphicsFile -Path "D:\Assets" -GraphicsType 3D -Recurse:$false
        Finds 3D assets in the top-level folder only.

    .EXAMPLE
        Find-GraphicsFile -Path "E:\Scans" -GraphicsType PointCloud -ExportCSV scans.csv -ShowDetails
        Finds point cloud files and exports a detailed CSV.

    .OUTPUTS
        PSCustomObject[]

    .INPUTS
        System.String

    .NOTES
        Author: gdelfavero
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [string]$Path = (Get-Location).Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('2D', '3D', 'PointCloud', 'All')]
        [string]$GraphicsType = 'All',

        [Parameter(Mandatory = $false)]
        [switch]$Recurse,

        [Parameter(Mandatory = $false)]
        [string]$ExportCSV,

        [Parameter(Mandatory = $false)]
        [string]$ExportJSON,

        [Parameter(Mandatory = $false)]
        [switch]$ShowDetails,

        [Parameter(Mandatory = $false)]
        [switch]$ShowBanner
    )

    begin {
        $twoDExtensions = @(
            '.psd', '.ai', '.eps', '.svg', '.pdf', '.indd', '.idml', '.sketch', '.fig', '.xd',
            '.cdr', '.afdesign', '.afphoto', '.afpub'
        )

        $threeDExtensions = @(
            '.fbx', '.obj', '.glb', '.gltf', '.stl', '.3ds', '.blend', '.dae', '.abc', '.max',
            '.step', '.stp', '.iges', '.igs', '.ifc', '.uasset', '.usdz', '.usd'
        )

        $pointCloudExtensions = @(
            '.las', '.laz', '.e57', '.pcd', '.pts', '.ptx', '.xyz', '.ply'
        )

        Write-Verbose "Function started with Path=$Path, GraphicsType=$GraphicsType"

        $infoParams = @{ InformationAction = 'Continue' }

        if ($ShowBanner) {
            Write-Information @infoParams "PsGraphicsFinder - Graphics Asset Scanner"
            Write-Information @infoParams "-----------------------------------------"
        }

        $useRecurse = if ($PSBoundParameters.ContainsKey('Recurse')) { [bool]$Recurse } else { $true }

        Write-Information @infoParams "Searching in: $Path"
        Write-Information @infoParams "Graphics Type: $GraphicsType"
        Write-Information @infoParams "Recursive: $useRecurse"
        Write-Information @infoParams ""

        $searchExtensions = @()
        switch ($GraphicsType) {
            '2D' { $searchExtensions = $twoDExtensions }
            '3D' { $searchExtensions = $threeDExtensions }
            'PointCloud' { $searchExtensions = $pointCloudExtensions }
            'All' { $searchExtensions = $twoDExtensions + $threeDExtensions + $pointCloudExtensions }
        }
    }

    process {
        try {
            $resolvedPath = Resolve-Path -LiteralPath $Path -ErrorAction Stop
        }
        catch {
            Write-Error "The specified path '$Path' does not exist." -ErrorAction Stop
            return
        }

        try {
            Write-Verbose "Scanning for graphics assets..."
            $startTime = Get-Date

            $allGraphicsFiles = if ($useRecurse) {
                Get-ChildItem -LiteralPath $resolvedPath -File -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $searchExtensions -contains $_.Extension.ToLower() }
            } else {
                Get-ChildItem -LiteralPath $resolvedPath -File -ErrorAction SilentlyContinue |
                    Where-Object { $searchExtensions -contains $_.Extension.ToLower() }
            }

            $endTime = Get-Date
            $duration = $endTime - $startTime

            $results = @()
            $twoDFiles = @()
            $threeDFiles = @()
            $pointCloudFiles = @()

            foreach ($file in $allGraphicsFiles) {
                $fileInfo = [PSCustomObject]@{
                    Name = $file.Name
                    Path = $file.FullName
                    Directory = $file.DirectoryName
                    Extension = $file.Extension.ToLower()
                    Size = $file.Length
                    SizeFormatted = Format-FileSize -Size $file.Length
                    Created = $file.CreationTime
                    Modified = $file.LastWriteTime
                    Type = ''
                }

                if ($twoDExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = '2D'
                    $twoDFiles += $fileInfo
                } elseif ($threeDExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = '3D'
                    $threeDFiles += $fileInfo
                } elseif ($pointCloudExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = 'PointCloud'
                    $pointCloudFiles += $fileInfo
                }

                $results += $fileInfo
            }

            Write-Information @infoParams "Search Results"
            Write-Information @infoParams "----------------"
            Write-Information @infoParams "Search completed in: $($duration.TotalSeconds.ToString('F2')) seconds"
            Write-Information @infoParams ""
            Write-Information @infoParams "Total files found: $($results.Count)"
            Write-Information @infoParams "  2D files:        $($twoDFiles.Count)"
            Write-Information @infoParams "  3D files:        $($threeDFiles.Count)"
            Write-Information @infoParams "  Point clouds:    $($pointCloudFiles.Count)"

            $totalSize = ($results | Measure-Object -Property Size -Sum).Sum
            Write-Information @infoParams ""
            Write-Information @infoParams "Total size: $(Format-FileSize -Size $totalSize)"

            if ($results.Count -gt 0) {
                Write-Information @infoParams ""
                Write-Information @infoParams "----------------------------------------"

                if ($ShowDetails) {
                    Write-Information @infoParams ""
                    Write-Information @infoParams "Detailed File List:"
                    Write-Information @infoParams "----------------------------------------"

                    foreach ($file in $results | Sort-Object Type, Name) {
                        Write-Information @infoParams ""
                        Write-Information @infoParams "[$($file.Type)] $($file.Name)"
                        Write-Information @infoParams "  Path:     $($file.Path)"
                        Write-Information @infoParams "  Size:     $($file.SizeFormatted)"
                        Write-Information @infoParams "  Created:  $($file.Created.ToString('yyyy-MM-dd HH:mm:ss'))"
                        Write-Information @infoParams "  Modified: $($file.Modified.ToString('yyyy-MM-dd HH:mm:ss'))"
                    }
                } else {
                    Write-Information @infoParams ""
                    Write-Information @infoParams "File List (use -ShowDetails for more information):"
                    Write-Information @infoParams "----------------------------------------"

                    foreach ($file in $results | Sort-Object Type, Name) {
                        Write-Information @infoParams "[$($file.Type.PadRight(10))] $($file.Name.PadRight(40)) $($file.SizeFormatted)"
                    }
                }

                Write-Information @infoParams ""
                Write-Information @infoParams "----------------------------------------"
            }

            if ($ExportCSV) {
                try {
                    $results | Select-Object Name, Type, Path, Directory, Extension, SizeFormatted, Created, Modified |
                        Export-Csv -Path $ExportCSV -NoTypeInformation -Encoding UTF8
                    Write-Information @infoParams ""
                    Write-Information @infoParams "[SUCCESS] Results exported to CSV: $ExportCSV"
                } catch {
                    Write-Warning "Failed to export to CSV: $_"
                }
            }

            if ($ExportJSON) {
                try {
                    $results | ConvertTo-Json -Depth 3 | Out-File -FilePath $ExportJSON -Encoding UTF8
                    Write-Information @infoParams ""
                    Write-Information @infoParams "[SUCCESS] Results exported to JSON: $ExportJSON"
                } catch {
                    Write-Warning "Failed to export to JSON: $_"
                }
            }

            if ($results.Count -gt 0) {
                Write-Information @infoParams ""
                Write-Information @infoParams "Extension Breakdown"
                Write-Information @infoParams "--------------------"

                $extensionStats = $results | Group-Object Extension |
                    Select-Object @{Name='Extension';Expression={$_.Name}},
                                  @{Name='Count';Expression={$_.Count}},
                                  @{Name='TotalSize';Expression={($_.Group | Measure-Object -Property Size -Sum).Sum}} |
                    Sort-Object Count -Descending

                foreach ($stat in $extensionStats) {
                    Write-Information @infoParams "  $($stat.Extension.PadRight(10)) $($stat.Count.ToString().PadLeft(5)) files  ($(Format-FileSize -Size $stat.TotalSize))"
                }
            }

            Write-Information @infoParams ""

            return $results
        }
        catch {
            Write-Error "An error occurred while searching for graphics files: $_"
        }
    }
}
