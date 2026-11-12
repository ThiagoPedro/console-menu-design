#requires -Version 5.1
<#
.SYNOPSIS
    Generic persistent menu controller; UI reads input, handlers execute application actions.
.DESCRIPTION
    Entries: array of @{ Key='1'; Label='...'; Section='...'; Action={ ... } }.
    Action is required except for ExitKey. Never invoke a child program requiring stdin.
#>
Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot '..\core\ConsoleDesign.psm1') -Force

function Start-CDMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [string]$Subtitle = '',
        [Parameter(Mandatory)][object[]]$Entries,
        [string]$ExitKey = '0',
        [string]$StatusText = 'Pronto para executar comandos.'
    )
    $seen = @{}
    foreach ($entry in $Entries) {
        if (-not $entry.Contains('Key') -or -not $entry.Contains('Label') -or -not $entry.Contains('Action')) {
            throw 'Each entry must define Key, Label, and Action.'
        }
        $key = [string]$entry.Key
        if ($seen.ContainsKey($key) -or $key -eq $ExitKey) { throw "Duplicate or reserved menu key: $key" }
        if ($entry.Action -isnot [scriptblock]) { throw "Action must be a scriptblock: $key" }
        $seen[$key] = $entry
    }
    while ($true) {
        Show-CDHeader -Title $Title -Subtitle $Subtitle
        $section = $null
        foreach ($entry in $Entries) {
            $nextSection = if ($entry.Contains('Section')) { [string]$entry.Section } else { '' }
            if ($nextSection -ne $section) {
                Write-CDText ''
                if ($nextSection) { Show-CDSection $nextSection }
                $section = $nextSection
            }
            Show-CDOption -Key ([string]$entry.Key) -Label ([string]$entry.Label)
        }
        Write-CDText ''
        Show-CDOption -Key $ExitKey -Label 'Sair'
        Write-CDText ''
        Show-CDStatus -Text $StatusText
        Write-CDText ''
        $key = Read-CDChoice -Prompt 'Selecione uma opcao' -ValidOptions (@($seen.Keys) + @($ExitKey))
        if ($key -eq $ExitKey) { return }
        $entry = $seen[$key]
        Show-CDHeader -Title ($Title + ' / ' + $entry.Label) -Subtitle 'Operacao em execucao'
        try { & $entry.Action } catch { Show-CDMessage -Kind Error -Text $_.Exception.Message }
        Pause-CDMenu
    }
}
Export-ModuleMember -Function Start-CDMenu
