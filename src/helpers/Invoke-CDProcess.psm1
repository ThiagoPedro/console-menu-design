#requires -Version 5.1
<#
.SYNOPSIS
    Safe noninteractive child process launcher for external application operations.
.NOTES
    No shell interpolation, no automatic elevation, and no UI input from child processes.
#>
Set-StrictMode -Version Latest
function Invoke-CDProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [string[]]$ArgumentList = @()
    )
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) { throw "Executavel nao encontrado: $FilePath" }
    & $FilePath @ArgumentList
    $result = [int]$LASTEXITCODE
    return $result
}
Export-ModuleMember -Function Invoke-CDProcess
