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

# Export public functions (Public folder functions are meant to be exported)
Export-ModuleMember -Function $PublicFunctions.BaseName
