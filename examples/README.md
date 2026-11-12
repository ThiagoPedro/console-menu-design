# Exemplos executáveis

Todos os exemplos são **demonstrativos**, não alteram o Registro, serviços, perfis ou configurações do Windows.

## Pré-requisitos

- Windows PowerShell 5.1 ou PowerShell 7+ (`pwsh.exe`).
- Terminal interativo para usar menus com `Read-Host`.
- Nenhuma dependência de módulos externos, fontes especiais ou Oh My Posh.

## Basic Menu

Execute `examples/basic-menu/Executar.bat` com duplo clique no Windows ou, na raiz do repositório:

```powershell
pwsh -NoProfile -File .\examples\basic-menu\BasicMenu.ps1
```

Exibe cabeçalho, categorias, opções numeradas, cores, mensagens semânticas, confirmação e retorno ao menu.

## Operations Demo

```powershell
pwsh -NoProfile -File .\examples\operations\OperationsDemo.ps1
```

Mostra como a UI recebe entradas e dispara funções não interativas. A operação de exemplo é um *dry-run* e a consulta de ambiente é somente leitura.

## Compatibilidade e tema

Em ambas as interfaces, `-Simple` desativa cores. No Basic Menu, `-Theme Monochrome` seleciona o tema monocromático. A saída pode variar conforme a configuração do console e da fonte.
