function Find-MediaFile {
    <#
    .SYNOPSIS
        Searches for media files (audio, video, pictures, and vaults) in a specified directory.

    .DESCRIPTION
        The Find-MediaFile function searches for media files in a specified directory.
        It supports recursive search, filtering by media type, and various output formats.
        Results can be displayed with detailed information and exported to CSV or JSON formats.

    .PARAMETER Path
        The directory path to search for media files. Defaults to the current directory.

    .PARAMETER MediaType
        The type of media to search for. Valid values: Audio, Video, Picture, Vaults, All
        Default: All

    .PARAMETER Recurse
        Search subdirectories recursively. Default: $true

    .PARAMETER ExportCSV
        Export results to a CSV file at the specified path.

    .PARAMETER ExportJSON
        Export results to a JSON file at the specified path.

    .PARAMETER ShowDetails
        Display detailed information about each file (size, creation date, modification date).

    .EXAMPLE
        Find-MediaFile
        Searches for all media files in the current directory and subdirectories.

    .EXAMPLE
        Find-MediaFile -Path "C:\Users\Documents" -MediaType Audio
        Searches for audio files only in the specified directory.

    .EXAMPLE
        Find-MediaFile -Path "D:\Media" -Recurse $false
        Searches for media files only in the specified directory (no subdirectories).

    .EXAMPLE
        Find-MediaFile -Path "C:\Media" -ExportCSV "media_results.csv" -ShowDetails
        Searches for all media files and exports detailed results to CSV.

    .OUTPUTS
        PSCustomObject[]
        Returns an array of custom objects containing file information.

    .NOTES
        Author: gdelfavero

    .INPUTS
        System.String
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [string]$Path = (Get-Location).Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Audio", "Video", "Picture", "Vaults", "All")]
        [string]$MediaType = "All",

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
        # Define media file extensions
        $audioExtensions = @('.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.wma', '.opus', '.aiff', '.ape')
        $videoExtensions = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.divx')
        $pictureExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.tif', '.svg', '.webp', '.ico', '.raw', '.heic')
        $vaultExtensions = @('.kdbx', '.1pif', '.agilekeychain', '.opvault', '.bw', '.enpass', '.psafe3', '.kdb', '.keepass', '.hc', '.tc')

        Write-Verbose "Function started with Path=$Path, MediaType=$MediaType"

        $infoParams = @{ InformationAction = 'Continue' }

        if ($ShowBanner) {
            Write-Information @infoParams "PsMediaFinder - Media File Scanner"
            Write-Information @infoParams "----------------------------------"
        }

        $useRecurse = if ($PSBoundParameters.ContainsKey('Recurse')) { [bool]$Recurse } else { $true }

        Write-Information @infoParams "Searching in: $Path"
        Write-Information @infoParams "Media Type: $MediaType"
        Write-Information @infoParams "Recursive: $useRecurse"
        Write-Information @infoParams ""

        # Determine which extensions to search for
        $searchExtensions = @()
        switch ($MediaType) {
            "Audio" { $searchExtensions = $audioExtensions }
            "Video" { $searchExtensions = $videoExtensions }
            "Picture" { $searchExtensions = $pictureExtensions }
            "Vaults" { $searchExtensions = $vaultExtensions }
            "All" { $searchExtensions = $audioExtensions + $videoExtensions + $pictureExtensions + $vaultExtensions }
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
            # Search for media files
            Write-Verbose "Scanning for media files..."
            $startTime = Get-Date

            $allMediaFiles = @()

            if ($useRecurse) {
                $allMediaFiles = Get-ChildItem -LiteralPath $resolvedPath -File -Recurse -ErrorAction SilentlyContinue |
                                 Where-Object { $searchExtensions -contains $_.Extension.ToLower() }
            } else {
                $allMediaFiles = Get-ChildItem -LiteralPath $resolvedPath -File -ErrorAction SilentlyContinue |
                                 Where-Object { $searchExtensions -contains $_.Extension.ToLower() }
            }

            $endTime = Get-Date
            $duration = $endTime - $startTime

            # Process and categorize results
            $results = @()
            $audioFiles = @()
            $videoFiles = @()
            $pictureFiles = @()
            $vaultFiles = @()

            foreach ($file in $allMediaFiles) {
                $fileInfo = [PSCustomObject]@{
                    Name = $file.Name
                    Path = $file.FullName
                    Directory = $file.DirectoryName
                    Extension = $file.Extension.ToLower()
                    Size = $file.Length
                    SizeFormatted = Format-FileSize -Size $file.Length
                    Created = $file.CreationTime
                    Modified = $file.LastWriteTime
                    Type = ""
                }

                # Determine file type
                if ($audioExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = "Audio"
                    $audioFiles += $fileInfo
                } elseif ($videoExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = "Video"
                    $videoFiles += $fileInfo
                } elseif ($pictureExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = "Picture"
                    $pictureFiles += $fileInfo
                } elseif ($vaultExtensions -contains $file.Extension.ToLower()) {
                    $fileInfo.Type = "Vaults"
                    $vaultFiles += $fileInfo
                }

                $results += $fileInfo
            }

            # Display summary (ASCII only for PS5 compatibility)
            Write-Information @infoParams "Search Results"
            Write-Information @infoParams "----------------"

            Write-Information @infoParams "Search completed in: $($duration.TotalSeconds.ToString('F2')) seconds"
            Write-Information @infoParams ""
            Write-Information @infoParams "Total files found: $($results.Count)"

            if ($MediaType -eq "All" -or $MediaType -eq "Audio") {
                Write-Information @infoParams "  Audio files:   $($audioFiles.Count)"
            }
            if ($MediaType -eq "All" -or $MediaType -eq "Video") {
                Write-Information @infoParams "  Video files:   $($videoFiles.Count)"
            }
            if ($MediaType -eq "All" -or $MediaType -eq "Picture") {
                Write-Information @infoParams "  Picture files: $($pictureFiles.Count)"
            }
            if ($MediaType -eq "All" -or $MediaType -eq "Vaults") {
                Write-Information @infoParams "  Vault files:   $($vaultFiles.Count)"
            }

            # Calculate total size
            $totalSize = ($results | Measure-Object -Property Size -Sum).Sum
            Write-Information @infoParams ""
            Write-Information @infoParams "Total size: $(Format-FileSize -Size $totalSize)"

            # Display detailed results
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
                        Write-Information @infoParams "[$($file.Type.PadRight(7))] $($file.Name.PadRight(40)) $($file.SizeFormatted)"
                    }
                }

                Write-Information @infoParams ""
                Write-Information @infoParams "----------------------------------------"
            }

            # Export results to CSV
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

            # Export results to JSON
            if ($ExportJSON) {
                try {
                    $results | ConvertTo-Json -Depth 3 | Out-File -FilePath $ExportJSON -Encoding UTF8
                    Write-Information @infoParams ""
                    Write-Information @infoParams "[SUCCESS] Results exported to JSON: $ExportJSON"
                } catch {
                    Write-Warning "Failed to export to JSON: $_"
                }
            }

            # Display extension breakdown
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

            # Return results
            return $results
        }
        catch {
            Write-Error "An error occurred while searching for media files: $_"
        }
    }
}
