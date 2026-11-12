#requires -Version 5.1
[CmdletBinding()]
param([switch]$Simple)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Import-Module (Join-Path $root 'src\core\ConsoleDesign.psm1') -Force
Import-Module (Join-Path $root 'src\components\Menu.psm1') -Force
Initialize-CDConsole -Simple:$Simple

# Demo operations: return typed objects or status; do not read from the console.
function Get-DemoEnvironment {
    return [pscustomobject]@{
        PowerShell = $PSVersionTable.PSVersion.ToString()
        OperatingSystem = [Environment]::OSVersion.VersionString
        Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }
}
function Invoke-DemoTask {
    param([Parameter(Mandatory)][string]$Name)
    if ($Name -ne 'dry-run') { throw 'Invalid task name.' }
    return [pscustomobject]@{ Success = $true; Detail = 'Dry-run executado sem gravacao de dados.' }
}
$entries = @(
    @{ Key='1'; Label='Consultar ambiente'; Section='DIAGNOSTICO'; Action={
        $result = Get-DemoEnvironment
        Write-CDText ('  PowerShell: ' + $result.PowerShell)
        Write-CDText ('  Sistema: ' + $result.OperatingSystem)
        Write-CDText ('  Data: ' + $result.Date)
    } },
    @{ Key='2'; Label='Executar operacao simulada'; Section='OPERACOES'; Action={
        if (-not (Confirm-CDAction 'Executar operacao de teste?')) {
            Show-CDMessage -Kind Warning -Text 'Cancelado antes da operacao.'
        } else {
            $result = Invoke-DemoTask -Name 'dry-run'
            if ($result.Success) { Show-CDMessage -Kind Success -Text $result.Detail }
            else { Show-CDMessage -Kind Error -Text $result.Detail }
        }
    } }
)
Start-CDMenu -Title 'CONSOLE DESIGN / OPERATIONS' -Subtitle 'Exemplo de separacao UI e operacoes' -Entries $entries -StatusText 'Apenas leitura e simulacao'
