# Código-fonte de interface

Módulos independentes de regras de negócio. A interface é responsável por apresentar telas, ler escolhas, validar confirmações e renderizar resultados. As operações devem ser não interativas.

| Diretório | Conteúdo | Contrato |
|---|---|---|
| `core/` | `ConsoleDesign.psm1` | Renderização, tema e entrada |
| `components/` | `Menu.psm1` | Menu persistente parametrizado por opções + ações |
| `themes/` | `Default.psd1`, `Monochrome.psd1` | Mapas de cores, largura e recuo |
| `helpers/` | `Invoke-CDProcess.psm1` | Execução não interativa de processos externos |

## Importação

```powershell
Import-Module .\src\core\ConsoleDesign.psm1
Import-Module .\src\components\Menu.psm1
Initialize-CDConsole -Theme Default
```

Execute o código da raiz do repositório. Para projetos derivados, resolva caminhos a partir de `$PSScriptRoot`, e não do diretório atual.

## Contrato do menu

Cada opção é uma hashtable contendo `Key`, `Label`, `Section` (opcional) e `Action` (`ScriptBlock`). As chaves não podem se repetir nem usar `ExitKey`.

```powershell
$entries = @(
    @{ Key='1'; Label='Consultar'; Section='FERRAMENTAS'; Action={ Show-CDMessage -Kind Info -Text 'Pronto' } }
)
Start-CDMenu -Title 'MEU PROJETO' -Entries $entries
```

`Start-CDMenu` é responsável pelo loop, entrada, tratamento de exceções da ação, pausa e retorno. `Action` não deve abrir prompts em processos filhos. Ações críticas devem utilizar `Confirm-CDAction` antes de executar qualquer mudança.

## Limites atuais

- Navegação por números com `Read-Host`; **não** há navegação por setas, mouse ou menus ANSI True Color.
- Mensagens utilizam `ConsoleColor` via `Write-Host`; fallback `-Simple` sem cor.
- Caracteres de moldura ASCII, sem dependência de Nerd Fonts.
- Janela muito estreita pode truncar títulos; não há quebra de linha sofisticada.
- A inicialização de encoding afeta apenas o processo corrente.
- Funções de domínio e elevação administrativa estão fora do escopo do framework.

## Extensibilidade

Ampliações devem preservar API e fallback simples, manter regras de negócio fora de `src`, evitar dependências externas obrigatórias e incluir testes em ambiente Windows real.
