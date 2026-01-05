# Get the module root path
$ModuleRoot = $PSScriptRoot

# Import all functions from Private folder (if any exist)
$PrivateFunctions = Get-ChildItem -Path "$ModuleRoot\Private\*.ps1" -ErrorAction SilentlyContinue

foreach ($function in $PrivateFunctions) {
    try {
        . $function.FullName
    }
    catch {
        Write-Error "Failed to import private function $($function.FullName): $_"
    }
}

# Import all functions from Public folder
$PublicFunctions = Get-ChildItem -Path "$ModuleRoot\Public\*.ps1" -ErrorAction SilentlyContinue

foreach ($function in $PublicFunctions) {
    try {
        . $function.FullName
    }
    catch {
        Write-Error "Failed to import public function $($function.FullName): $_"
    }
}

# Export public functions and legacy aliases
Set-Alias -Name Find-MediaFiles -Value Find-MediaFile -ErrorAction SilentlyContinue
Set-Alias -Name Find-MsOfficeFiles -Value Find-MsOfficeFile -ErrorAction SilentlyContinue
Set-Alias -Name Find-GraphicsFiles -Value Find-GraphicsFile -ErrorAction SilentlyContinue
Export-ModuleMember -Function Find-MediaFile, Find-MsOfficeFile, Find-GraphicsFile -Alias Find-MediaFiles, Find-MsOfficeFiles, Find-GraphicsFiles
