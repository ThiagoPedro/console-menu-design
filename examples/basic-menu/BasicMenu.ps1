#requires -Version 5.1
[CmdletBinding()]
param([switch]$Simple, [ValidateSet('Default','Monochrome')][string]$Theme = 'Default')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Import-Module (Join-Path $root 'src\core\ConsoleDesign.psm1') -Force
Import-Module (Join-Path $root 'src\components\Menu.psm1') -Force
Initialize-CDConsole -Simple:$Simple -Theme $Theme
$entries = @(
    @{ Key='1'; Label='Exibir saudacao'; Section='DEMONSTRACAO'; Action={ Show-CDMessage -Kind Success -Text 'O menu reutilizavel esta funcionando.' } },
    @{ Key='2'; Label='Exibir mensagens e estados'; Section='DEMONSTRACAO'; Action={
        Show-CDMessage -Kind Info -Text 'Informacao operacional.'
        Show-CDMessage -Kind Success -Text 'Operacao concluida.'
        Show-CDMessage -Kind Warning -Text 'Atencao a esta condicao.'
        Show-CDMessage -Kind Error -Text 'Exemplo de mensagem de erro.'
    } },
    @{ Key='3'; Label='Confirmar uma acao simulada'; Section='INTERACAO'; Action={
        if (Confirm-CDAction 'Deseja simular a operacao?') {
            Show-CDMessage -Kind Success -Text 'Simulacao confirmada; nenhum arquivo foi alterado.'
        } else { Show-CDMessage -Kind Warning -Text 'Simulacao cancelada.' }
    } }
)
Start-CDMenu -Title 'CONSOLE DESIGN / BASIC MENU' -Subtitle 'Exemplo reutilizavel, sem alteracoes no sistema' -Entries $entries -StatusText 'Modo demonstracao | Nenhuma alteracao persistente'
