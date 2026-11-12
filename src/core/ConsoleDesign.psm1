#requires -Version 5.1
<#
.SYNOPSIS
    Reusable console presentation primitives for Windows PowerShell 5.1 / PowerShell 7+.
.DESCRIPTION
    UI only. No application-specific operations, privilege escalation, or persistent
    terminal/profile configuration. All interactive input belongs to this module.
#>
Set-StrictMode -Version Latest
$script:Theme = $null
$script:UseColor = $true
$script:Simple = $false

function Initialize-CDConsole {
    [CmdletBinding()]
    param(
        [ValidateSet('Default','Monochrome')][string]$Theme = 'Default',
        [switch]$Simple
    )
    $themeFile = Join-Path (Join-Path $PSScriptRoot '..\themes') ($Theme + '.psd1')
    $script:Theme = Import-PowerShellDataFile -LiteralPath $themeFile
    $script:Simple = [bool]$Simple
    $script:UseColor = -not $Simple -and -not [Console]::IsOutputRedirected
    try {
        [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
        $global:OutputEncoding = [Console]::OutputEncoding
    } catch { } # Output encoding may be locked in redirected/non-console hosts.
}

function Assert-CDInitialized {
    if ($null -eq $script:Theme) { Initialize-CDConsole }
}

function Write-CDText {
    [CmdletBinding()]
    param(
        [AllowEmptyString()][string]$Text = '',
        [ValidateSet('Border','Title','Category','Text','Muted','Info','Success','Warning','Error')]
        [string]$Tone = 'Text',
        [switch]$NoNewline
    )
    Assert-CDInitialized
    if ($script:UseColor) {
        $color = [ConsoleColor]$script:Theme.Colors[$Tone]
        Write-Host $Text -ForegroundColor $color -NoNewline:$NoNewline
    } else {
        Write-Host $Text -NoNewline:$NoNewline
    }
}

function Get-CDContentWidth {
    Assert-CDInitialized
    $maxWidth = [int]$script:Theme.Width
    $minWidth = [int]$script:Theme.MinimumWidth
    $margin = [int]$script:Theme.Indent
    try {
        $available = [Console]::WindowWidth - ($margin * 2)
        if ($available -gt 0) { return [Math]::Min($maxWidth, [Math]::Max(1,$available)) }
    } catch { }
    return [Math]::Max($minWidth,$maxWidth)
}

function Format-CDLine {
    [CmdletBinding()]
    param([AllowEmptyString()][string]$Value = '')
    $max = Get-CDContentWidth
    if ($Value.Length -le $max) { return $Value }
    if ($max -lt 4) { return $Value.Substring(0, $max) }
    return $Value.Substring(0,$max - 3) + '...'
}

function Show-CDHeader {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Title, [string]$Subtitle = '', [switch]$NoClear)
    Assert-CDInitialized
    if (-not $NoClear) { try { Clear-Host } catch { } }
    $indent = ' ' * [int]$script:Theme.Indent
    $line = $indent + ('=' * (Get-CDContentWidth))
    Write-CDText ''
    Write-CDText $line Border
    Write-CDText ($indent + (Format-CDLine $Title)) Title
    if ($Subtitle) { Write-CDText ($indent + (Format-CDLine $Subtitle)) Muted }
    Write-CDText $line Border
    Write-CDText ''
}

function Show-CDSection {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Title)
    Write-CDText ('    ' + (Format-CDLine $Title)) Category
}

function Show-CDOption {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)][string]$Label)
    Write-CDText ('    [{0}]  ' -f $Key) Title -NoNewline
    Write-CDText (Format-CDLine $Label) Text
}

function Show-CDMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [ValidateSet('Info','Success','Warning','Error')][string]$Kind = 'Info'
    )
    $prefix = @{ Info='INFO'; Success='OK'; Warning='AVISO'; Error='ERRO' }[$Kind]
    Write-CDText ('  [{0}] {1}' -f $prefix,$Text) $Kind
}

function Show-CDStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text)
    $width = [Math]::Min(48,(Get-CDContentWidth))
    Write-CDText ('  ' + ('-' * $width)) Border
    Write-CDText ('  ' + (Format-CDLine $Text)) Muted
}

function Read-CDChoice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Prompt,
        [Parameter(Mandatory)][string[]]$ValidOptions,
        [string]$CancelOption = '0'
    )
    if (-not $ValidOptions.Count) { throw 'ValidOptions must not be empty.' }
    while ($true) {
        $answer = Read-Host ('  ' + $Prompt)
        if ($null -eq $answer) { return $CancelOption }
        $answer = $answer.Trim()
        if ($ValidOptions -contains $answer) { return $answer }
        Show-CDMessage -Kind Warning -Text 'Opcao invalida. Tente novamente.'
    }
}

function Confirm-CDAction {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Question)
    Write-CDText ''
    Write-CDText ('  ' + $Question) Warning
    $answer = Read-CDChoice -Prompt 'Confirmar [S/N]' -ValidOptions @('S','s','N','n') -CancelOption 'N'
    return ($answer.ToUpperInvariant() -eq 'S')
}

function Pause-CDMenu {
    [CmdletBinding()]
    param([string]$Prompt = 'Pressione ENTER para retornar ao menu')
    Write-CDText ''
    [void](Read-Host ('  ' + $Prompt))
}

Export-ModuleMember -Function Initialize-CDConsole, Write-CDText, Get-CDContentWidth, Show-CDHeader, Show-CDSection, Show-CDOption, Show-CDMessage, Show-CDStatus, Read-CDChoice, Confirm-CDAction, Pause-CDMenu
