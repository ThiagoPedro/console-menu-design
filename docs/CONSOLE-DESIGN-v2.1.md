# CHECKPOINT TÉCNICO — CONSOLE DESIGN v2.1

**Classificação:** padrão técnico reutilizável de interface de linha de comando (CLI/TUI)  
**Plataforma-alvo:** Windows 11, Windows Terminal e console Windows compatível  
**Implementação de referência:** inicializador `.bat` + interface `.ps1`  
**Estado:** características de layout e fluxo confirmadas em uso pelo usuário; não implica testes automatizados de portabilidade  
**Escopo:** exclusivamente identidade visual, renderização, estrutura de telas, navegação e arquitetura de interface. Nenhuma regra de negócio integra este checkpoint.

---

## 1. Objetivo e princípio de reutilização

Padronizar interfaces administrativas de console com apresentação sóbria, hierarquia visual consistente, menu persistente e separação obrigatória entre apresentação e operações. O padrão deve ser transportável para qualquer domínio: automação, manutenção, diagnóstico, configuração, execução de rotinas ou administração de serviços.

**Princípios normativos:**

1. A interface **não** deve codificar regras específicas do domínio em funções de apresentação.
2. A interface é responsável por **perguntar, validar, confirmar, apresentar e reportar**; a camada operacional recebe argumentos definidos e retorna resultados.
3. O processo operacional não deve competir com a interface pela entrada interativa do console.
4. Os rótulos, opções e ações devem ser substituíveis sem alterar o motor visual.
5. O design deve manter legibilidade sem cores, caracteres gráficos especiais ou fontes adicionais.
6. A funcionalidade nunca deve depender exclusivamente de cor ou de símbolos decorativos.

## 2. Arquitetura técnica de referência

```text
Inicializador.bat
    ├── valida arquivos básicos e ambiente
    ├── prefere pwsh.exe (PowerShell 7+)
    └── fallback: powershell.exe (Windows PowerShell 5.1)
         │
         ▼
ConsoleUI.ps1                     CAMADA DE INTERFACE
    ├── configura codificação de saída
    ├── seleciona modo visual / fallback simples
    ├── desenha cabeçalho, seções, opções e status
    ├── captura e valida entrada do usuário
    ├── apresenta confirmações e feedback
    ├── despacha ação + argumentos tipados/validados
    └── interpreta código de retorno
         │
         ▼
Operacao.ps1 / executável          CAMADA OPERACIONAL
    ├── aceita parâmetros explícitos
    ├── executa sem prompts interativos
    └── devolve código de saída e mensagens de resultado
```

**Observação:** os nomes dos arquivos são papéis arquiteturais ilustrativos, não requisitos de nomenclatura. O backend pode ser qualquer executável ou linguagem, desde que respeite o contrato de não interatividade.

### 2.1 Fronteira de entrada

- `ConsoleUI` é o **único proprietário de `Read-Host`**, de menus de seleção e de confirmações.
- A operação recebe opções já validadas, preferencialmente por parâmetros nomeados.
- Uma operação elevada ou iniciada em processo filho não deve requisitar `Read-Host` nem desenhar menus; isso evita tela vazia, prompt isolado e conflitos de stdin.
- A interface deve informar cancelamento antes de invocar a operação.

## 3. Identidade visual consolidada

| Elemento | Padrão confirmado | Diretriz |
|---|---|---|
| Fundo | Fundo de console escuro | `color 07` no BAT de referência; não alterar tema global do terminal |
| Divisórias | Azul | `ConsoleColor.Blue`, linha de `=` ou `-` |
| Título / índice de opção | Ciano | `ConsoleColor.Cyan` |
| Títulos de categoria | Branco | `ConsoleColor.White` |
| Subtítulo, contexto e status | Cinza escuro | `ConsoleColor.DarkGray` |
| Texto operacional | Branco | `ConsoleColor.White` |
| Aviso / confirmação relevante | Amarelo | `ConsoleColor.Yellow` |
| Erro | Vermelho | `ConsoleColor.Red` |
| Sucesso | Verde | `ConsoleColor.Green` |
| Tipografia | Monoespaçada | Compatível com fonte padrão de console; Nerd Fonts não é obrigatória |
| Iconografia | Não necessária | Padrão confirmado usa texto simples; ícones são evolução opcional |
| Moldura | Divisórias horizontais | Sem depender de box-drawing Unicode |

**Não confundir implementação com proposta:** a versão consolidada utiliza `Write-Host -ForegroundColor` e cores da enumeração `ConsoleColor`; **não utiliza ANSI True Color, bordas Unicode, mouse, atalhos por setas nem renderização diferencial de tela**.

### 3.1 Geometria e espaçamento

- Cabeçalho com linha em branco inicial, linha de `=`, título, subtítulo, segunda linha de `=` e linha em branco final.
- Recuo visual de **2 espaços** para linhas principais (divisórias e status) e **4 espaços** para categorias e opções.
- Entre categorias, inserir uma linha em branco.
- Índices no formato `    [N]  `, com o número em ciano e a descrição em branco.
- Divisória inferior de status com `-` de comprimento reduzido em relação ao cabeçalho.
- Evitar textos longos nas opções; dividir detalhes secundários em linhas próprias quando necessário.

### 3.2 Largura do cabeçalho

Regra efetivamente usada:

```powershell
$width = 69
try {
    $width = [Math]::Max(45, [Math]::Min(69, [Console]::WindowWidth - 6))
} catch {}
$line = '  ' + ('=' * $width)
```

- O padrão busca largura de **69 caracteres** para a divisória principal.
- Em janelas menores, reduz até **45 caracteres** conforme a fórmula.
- Em caso de exceção na leitura do console, usa 69.
- **Limite conhecido:** em janelas extremamente estreitas, a largura mínima de 45 pode exceder o espaço disponível. Não classificar este algoritmo como responsividade irrestrita.
- Recomenda-se truncamento ou quebra controlada dos títulos longos em implementações futuras, preservando a simplicidade do padrão atual.

## 4. Composição visual de tela

```text
  =====================================================================
  TITULO DO SISTEMA  /  SECAO
  Descricao breve do painel - contexto de execucao
  =====================================================================

    CATEGORIA PRINCIPAL
    [1]  Primeira operacao
    [2]  Segunda operacao
    [3]  Terceira operacao

    FERRAMENTAS
    [4]  Consultar informacoes
    [5]  Executar manutencao

    SISTEMA
    [0]  Sair

  ------------------------------------------------
  Ambiente: <versao>  |  <estado relevante>
  Aviso permanente curto, quando aplicavel.

  Selecione uma opcao [0-5]: _
```

**Nota:** este desenho demonstra hierarquia e recuo, não impõe esses rótulos ou esta quantidade de itens. O status deve refletir informação real, jamais valores ilustrativos no programa executável.

### 4.1 Telas de operação

- Ao selecionar uma opção válida, limpar a tela e apresentar novamente o cabeçalho com **nome da seção/ação**.
- Mostrar instruções, opções ou confirmações *na própria interface*, antes de chamar o backend.
- Exibir mensagens da operação no mesmo contexto visual, indicando sucesso, aviso, cancelamento ou erro.
- Após a conclusão, oferecer `ENTER` para retornar ao menu principal.
- O menu principal é persistente, implementado por laço `while ($true)` com `Clear-Host` no início de cada renderização.

## 5. Contrato mínimo de funções de interface

API conceitual derivada da implementação consolidada:

| Função de interface | Responsabilidade |
|---|---|
| `Screen-Header(Heading, Subheading)` | Limpar tela, calcular largura e exibir título/subtítulo e divisórias |
| `Say(Value, Tone, NoNewline)` | Escrever texto com cor sem dispersar lógica de estilo |
| `Option(Number, Title)` | Exibir opção numerada com índice destacado |
| `Status-Label()` | Exibir status/resumo do ambiente, preenchido pelo projeto |
| `Read-Menu(Prompt)` | Capturar entrada de texto e devolver valor normalizado |
| `Confirm-Action(Message)` | Exigir confirmação explícita, padrão negativo |
| `Pause-Menu()` | Aguardar ENTER antes do retorno |
| `Execute-Backend(Action, Elevate, Options)` | Despachar operação com argumentos validados, aguardar e reportar resultado |
| `Log-Event(Message)` | Registrar evento da interface sem misturar saída operacional |

**Padrão de cor usado:** mapa nominal de tons `Blue`, `Cyan`, `White`, `Grey`, `Yellow`, `Red`, `Green` para valores de `[ConsoleColor]`. `-NoNewline` permite compor linhas com índice colorido e texto comum.

### 5.1 Contrato de retorno

O padrão de referência interpreta:

| Código | Estado visual | Interpretação |
|---|---|---|
| `0` | Verde `[OK]` | Operação concluída |
| `2` | Amarelo `[AVISO]` | Cancelamento informado pelo backend |
| Outros | Vermelho `[ERRO]` | Falha ou código não reconhecido |

**Regra de engenharia:** os códigos devem ser declarados no contrato da aplicação. Não pressupor que todos os sistemas empreguem `2` para cancelamento. Um cancelamento na própria UI não deve invocar o backend.

## 6. Entrada, interação e validação

- **Padrão confirmado:** opções numeradas por `Read-Host`; não exige suporte a teclas especiais.
- Zerar/normalizar entrada conforme o contexto, aplicar `Trim()` e comparar explicitamente com opções permitidas.
- Opção `0` destinada a sair ou cancelar no contexto da tela; não usá-la para mutações.
- Valor inválido apresenta `[AVISO]`, registra o evento quando aplicável e retorna ao menu.
- A confirmação de operação potencialmente modificadora deve ser explícita, p.ex. `S/N`; só `S` autoriza prosseguimento.
- Perguntas e confirmações são resolvidas **antes** de qualquer operação que dependa dos dados.
- O menu deve continuar acessível após sucesso, erro ou cancelamento recuperável.
- Não reproduzir a lógica do backend na camada visual: a UI valida formato/opções, enquanto o backend revalida condições de segurança e pré-requisitos.

## 7. Codificação e compatibilidade

### 7.1 Inicializador BAT

```bat
@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
color 07
```

- `DisableDelayedExpansion` evita expansão inesperada de `!` em caminhos e argumentos.
- `%~dp0` localiza arquivos relativos ao próprio inicializador.
- Validar arquivos necessários antes de iniciar a interface.
- Preferir `pwsh.exe` quando disponível; caso contrário, chamar `powershell.exe` com opção de interface simples.
- Encaminhar `%ERRORLEVEL%` à chamada que iniciou o BAT.
- `-NoLogo -NoProfile` torna a apresentação menos dependente do ambiente pessoal do operador.
- Não exigir Oh My Posh, Nerd Fonts ou alteração do perfil de usuário.

### 7.2 Interface PowerShell

- Definir `$ErrorActionPreference = 'Stop'` para falhas tratáveis por `try/catch`.
- Tentar `[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)` para saída UTF-8 sem BOM (considerar sintaxe compatível com a versão-alvo).
- Usar `Write-Host -ForegroundColor` apenas quando cores estiverem habilitadas.
- Detectar saída redirecionada via `[Console]::IsOutputRedirected`; nesse caso desativar aplicação de cores.
- Expor modo `-Simple` para renderização sem realces cromáticos.
- Como o modo simples **não altera a geometria do menu** na implementação consolidada, não descrevê-lo como uma interface alternativa completa.

### 7.3 Fallback e limites

- Se a largura do console não puder ser obtida, usar largura padrão.
- Se houver redirecionamento de saída, retirar cores sem alterar o conteúdo textual.
- Não depender de sequência ANSI RGB nem fontes de ícones na versão de referência.
- Compatibilidade visual em PowerShell 5.1 e 7+ é objetivo do design; o uso do padrão em outro projeto requer testes no sistema e terminal reais.

## 8. Padrão de mensagens e estado

| Classe | Prefixo | Cor | Aplicação |
|---|---|---|---|
| Informação | `[INFO]` | Ciano | Início ou andamento de tarefa |
| Sucesso | `[OK]` | Verde | Conclusão confirmada |
| Aviso | `[AVISO]` | Amarelo | Cancelamento, restrição ou efeito pendente |
| Erro | `[ERRO]` | Vermelho | Falha de validação ou de execução |
| Contexto | Sem prefixo | Cinza | Informações adicionais e orientações |

- A cor é reforço semântico, nunca o único indicador.
- Mensagens devem mencionar efeito confirmado, não sucesso presumido.
- Um estado do sistema (p.ex. disponibilidade de backup, versão do shell, conexão) deve vir de consulta real.
- Notificações de reinício, permissão ou alteração global pertencem ao contexto da operação; **não** são obrigatórias em todo menu.

## 9. Logging da interface

Padrão de referência: mensagens simples com timestamp e identificador de evento, em arquivo persistente isolado dos resultados do backend.

```text
YYYY-MM-DD HH:mm:ss | MENU_INICIADO
YYYY-MM-DD HH:mm:ss | OPERACAO_INICIO <ACAO>
YYYY-MM-DD HH:mm:ss | OPERACAO_FIM <ACAO> RC=<CODIGO>
YYYY-MM-DD HH:mm:ss | MENU_ENCERRADO
```

- O diretório de log é **configurável por projeto**; evitar caminhos rígidos no motor visual.
- Falha de escrita do log não deve derrubar uma consulta ou navegação de menu; comunicar aviso.
- O log não deve conter senhas, tokens, dados pessoais nem entradas sensíveis.
- Não confundir log da UI (navegação/resultado) com log operacional detalhado.

## 10. Elevação e separação de responsabilidade

- O menu deve rodar preferencialmente **sem privilégios administrativos**.
- Elevar somente ações que necessitem de privilégio adicional e após confirmação explícita.
- O processo elevado deve receber argumentos fixados/validados e executar **sem interação de stdin**.
- A interface deve capturar código de retorno e exibir feedback.
- Elevação, política de execução e compatibilidade do backend são decisões do aplicativo: **não fazem parte da identidade visual** e não devem ser acopladas ao renderizador.

## 11. Critérios objetivos de aceitação

Checklist para adoção do padrão em outros projetos:

- [ ] Título, subtítulo e divisórias seguem a mesma hierarquia visual.
- [ ] Azul/ciano/branco/cinza comunicam estrutura; amarelo/vermelho/verde comunicam estado.
- [ ] Categorias são separadas por linha em branco.
- [ ] Índices numerados mantêm alinhamento uniforme.
- [ ] `Screen-Header`, `Option`, `Say` e entrada de menu não contêm regras específicas do domínio.
- [ ] O status mostrado é obtido do ambiente real.
- [ ] O menu persiste após ações, falhas recuperáveis ou cancelamentos.
- [ ] Entradas inválidas não executam operações.
- [ ] Confirmações ocorrem na UI e nunca em processo filho não interativo.
- [ ] Terminal com saída redirecionada ou modo simples mantém legibilidade.
- [ ] O retorno do backend é traduzido em mensagem textual e código rastreável.
- [ ] As referências de arquivos são relativas à pasta do inicializador ou configuradas explicitamente.
- [ ] Testes cobrem pelo menos menu principal, uma operação, cancelamento, opção inválida, falha do backend e retorno ao menu.

## 12. Extensões futuras — **não implementadas no checkpoint v2.1**

As seguintes técnicas são **candidatas a evolução**, e não devem ser tratadas como características já disponíveis:

1. **ANSI 24-bit RGB / Virtual Terminal:** paleta ampliada, exigindo detecção de suporte e fallback.
2. **Caracteres Unicode de moldura:** caixas e divisórias mais elaboradas, com testes de largura, encoding e fontes.
3. **Navegação por setas, ENTER e ESC:** leitura de teclas sem linha de comando; requer API de entrada consistente.
4. **Redesenho parcial:** mover cursor e atualizar apenas regiões modificadas para reduzir cintilação.
5. **Layout estreito:** adaptação real a terminais com menos de 45 colunas, quebra/truncamento controlado.
6. **Temas configuráveis:** tokens visuais sem duplicar renderização.
7. **Acessibilidade:** modo de alto contraste, conteúdo legível sem cor e redução de decoração.
8. **Nerd Fonts e ícones:** opcionais, nunca pré-requisitos funcionais.
9. **Oh My Posh:** ferramenta de personalização do prompt, **não** motor de menus; sua instalação não aprimora automaticamente menus de aplicativos.

## 13. Instrução de reutilização em novos projetos

Ao iniciar um novo projeto de console:

1. Copiar **somente** o contrato de UI, os tokens de estilo, a estrutura das telas e os critérios de aceitação deste checkpoint.
2. Substituir título, categorias, opções, textos e indicadores por valores do novo domínio.
3. Implementar um adaptador de ações que receba opção selecionada e parâmetros validados.
4. Manter processos operacionais sem `Read-Host`, `set /p` ou confirmações paralelas.
5. Validar menu, cancelamento, erro, fallback, apresentação de status e retorno ao menu.
6. Documentar separadamente extensões além da v2.1; não afirmar suporte sem testes.

**Contrato de preservação:** evoluções visuais não podem alterar seleção, semântica de confirmação, segurança, resultado das operações ou códigos de retorno. Se uma mudança de aparência exigir modificação operacional, ela deve ser revisada e testada como mudança funcional independente.

---

**Identificador do padrão:** `CONSOLE-DESIGN-v2.1`  
**Escopo deste registro:** estritamente técnico e independente de cenário de negócio.  
**Base de evidência:** leitura estática dos scripts da versão v2.1 e confirmação do usuário de que o layout funcionou no Windows. Não se afirma execução automatizada ou testes multiplataforma.
