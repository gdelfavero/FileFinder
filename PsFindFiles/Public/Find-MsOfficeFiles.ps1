function Find-MsOfficeFiles {
    <#
    .SYNOPSIS
        Finds Microsoft Office files in a specified path.
    
    .DESCRIPTION
        The Find-MsOfficeFiles function searches for Microsoft Office files (Word, Excel, PowerPoint, Access, etc.)
        in a specified directory and optionally in its subdirectories. It supports both legacy and modern Office formats.
    
    .PARAMETER Path
        The path to search for Microsoft Office files. Defaults to the current directory.
    
    .PARAMETER Recurse
        If specified, searches subdirectories recursively.
    
    .PARAMETER IncludeLegacy
        If specified, includes legacy Office formats (.doc, .xls, .ppt) in addition to modern formats.
    
    .EXAMPLE
        Find-MsOfficeFiles
        Finds all modern Microsoft Office files in the current directory.
    
    .EXAMPLE
        Find-MsOfficeFiles -Path "C:\Documents" -Recurse
        Finds all modern Microsoft Office files in C:\Documents and its subdirectories.
    
    .EXAMPLE
        Find-MsOfficeFiles -Path "C:\Documents" -Recurse -IncludeLegacy
        Finds all Microsoft Office files (both modern and legacy formats) in C:\Documents and its subdirectories.
    
    .OUTPUTS
        System.IO.FileInfo

    .INPUTS
        System.String

    .NOTES
        Author: gdelfavero
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [string]$Path = (Get-Location).Path,
        
        [Parameter(Mandatory = $false)]
        [switch]$Recurse,
        
        [Parameter(Mandatory = $false)]
        [switch]$IncludeLegacy
    )
    
    begin {
        # Modern Office file extensions (Office 2007+)
        $modernExtensions = @(
            '*.docx',  # Word Document
            '*.docm',  # Word Macro-Enabled Document
            '*.dotx',  # Word Template
            '*.dotm',  # Word Macro-Enabled Template
            '*.xlsx',  # Excel Workbook
            '*.xlsm',  # Excel Macro-Enabled Workbook
            '*.xltx',  # Excel Template
            '*.xltm',  # Excel Macro-Enabled Template
            '*.xlsb',  # Excel Binary Workbook
            '*.pptx',  # PowerPoint Presentation
            '*.pptm',  # PowerPoint Macro-Enabled Presentation
            '*.potx',  # PowerPoint Template
            '*.potm',  # PowerPoint Macro-Enabled Template
            '*.ppsx',  # PowerPoint Show
            '*.ppsm',  # PowerPoint Macro-Enabled Show
            '*.accdb', # Access Database
            '*.accde'  # Access Execute Only Database
        )
        
        # Legacy Office file extensions (Office 97-2003)
        $legacyExtensions = @(
            '*.doc',   # Word Document
            '*.dot',   # Word Template
            '*.xls',   # Excel Workbook
            '*.xlt',   # Excel Template
            '*.ppt',   # PowerPoint Presentation
            '*.pot',   # PowerPoint Template
            '*.pps',   # PowerPoint Show
            '*.mdb'    # Access Database
        )
        
        # Determine which extensions to use
        $extensions = $modernExtensions
        if ($IncludeLegacy) {
            $extensions += $legacyExtensions
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
            foreach ($extension in $extensions) {
                $searchParams = @{
                    LiteralPath = $resolvedPath
                    Filter      = $extension
                    File        = $true
                    ErrorAction = 'SilentlyContinue'
                }
                
                if ($Recurse) {
                    $searchParams['Recurse'] = $true
                }
                
                Get-ChildItem @searchParams
            }
        }
        catch {
            Write-Error "An error occurred while searching for files: $_"
        }
    }
}
