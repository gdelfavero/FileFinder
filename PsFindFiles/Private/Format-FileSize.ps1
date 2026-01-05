function Format-FileSize {
    <#
    .SYNOPSIS
        Formats a file size in bytes to a human-readable string.

    .DESCRIPTION
        Converts a file size in bytes to a human-readable format (GB, MB, KB, or bytes).

    .PARAMETER Size
        The file size in bytes.

    .EXAMPLE
        Format-FileSize -Size 1073741824
        Returns "1.00 GB"

    .OUTPUTS
        String
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [long]$Size
    )

    if ($Size -gt 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    } elseif ($Size -gt 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    } elseif ($Size -gt 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    } else {
        return "{0} bytes" -f $Size
    }
}
