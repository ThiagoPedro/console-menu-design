# Windows Console Design

> Padrões, componentes e práticas de interface para aplicações de console no Windows.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

## Visão geral

Este repositório reúne uma base **evolutiva e independente de aplicação** para criar interfaces modernas em console Windows. Seu objetivo é padronizar a experiência visual e a interação em ferramentas administrativas, utilitários e scripts, sem limitar o projeto a uma versão, tema ou solução específica.

O foco inicial é a integração entre **Batch (`.bat`/`.cmd`)**, **PowerShell** e **Windows Terminal**. Outros recursos e abordagens poderão ser adicionados conforme forem implementados e validados.

## Objetivos

- Definir padrões consistentes de cores, espaçamento, tipografia, cabeçalhos e menus.
- Construir componentes de interface reutilizáveis e desacoplados das regras de negócio.
- Oferecer navegação, mensagens de estado, confirmação e tratamento de erros claros.
- Preservar compatibilidade e oferecer alternativas quando um terminal não suportar recursos avançados.
- Documentar decisões técnicas, limitações, verificações e evolução de versões.
- Facilitar a adoção em projetos independentes, com os devidos créditos de autoria.

## Princípios de design

1. **Interface separada da operação:** apresentação e entrada de dados não devem ficar misturadas com ações administrativas.
2. **Comportamento previsível:** menus persistentes, opções identificadas, cancelamento seguro e retorno consistente.
3. **Legibilidade:** contrastes adequados, mensagens objetivas e largura ajustável conforme o terminal.
4. **Progressividade:** recursos modernos quando disponíveis, sem dependências desnecessárias.
5. **Consistência:** padrões visuais e semânticos comuns a diferentes ferramentas.
6. **Evolução controlada:** não confundir funcionalidades propostas com recursos já implementados e testados.

## Tecnologias e compatibilidade

| Tecnologia | Papel no projeto |
| --- | --- |
| Batch / CMD | Inicialização e compatibilidade com ferramentas Windows |
| PowerShell | Interface modular, validação de entradas e apresentação dinâmica |
| Windows Terminal | Ambiente de execução com renderização moderna |
| ANSI / Virtual Terminal | Recursos opcionais de cores e controle de tela, conforme suporte |
| UTF-8 / Unicode | Textos, símbolos e bordas, quando compatíveis |

O funcionamento de cada implementação deve documentar a versão mínima exigida do PowerShell e os recursos efetivamente suportados. Fontes especiais, temas externos e ferramentas de customização do prompt são opcionais.

## Organização sugerida

```text
Windows-Console-Design/
├── README.md
├── LICENSE
├── NOTICE
├── .gitignore
├── docs/
│   ├── checkpoints/
│   └── guidelines/
├── src/
│   ├── core/
│   ├── components/
│   └── themes/
├── examples/
└── tests/
```

> A estrutura acima é um **direcionamento**, não uma afirmação de que todos os diretórios e componentes já existem. Adicione-os à medida que forem necessários.

## Checkpoints técnicos

Os checkpoints registram padrões e decisões de arquitetura visual. Novas versões podem aperfeiçoar o design sem alterar retrospectivamente o que já foi validado.

Recomenda-se que cada checkpoint registre:

- Identificação e escopo da versão.
- Recursos implementados e recursos planejados, separadamente.
- Contratos de navegação e interação.
- Paleta, hierarquia visual, dimensões e mensagens.
- Requisitos de compatibilidade e mecanismos de fallback.
- Testes realizados, ambiente de teste e limitações conhecidas.

## Uso em outros projetos

Os componentes podem ser adaptados a finalidades diferentes. Recomenda-se manter a camada de apresentação independente da lógica operacional e registrar mudanças relevantes em código reutilizado.

## Contribuições

Correções, propostas de componentes, melhorias de acessibilidade e testes em diferentes terminais são bem-vindos. Uma contribuição deve descrever seu objetivo, compatibilidade e como foi validada. Alterações em componentes compartilhados não devem introduzir dependências obrigatórias sem justificativa.

## Licença e autoria

Este projeto é disponibilizado sob a **Apache License, Version 2.0**. Consulte o arquivo [`LICENSE`](LICENSE) e os avisos de atribuição em [`NOTICE`](NOTICE).

Ao redistribuir o material ou trabalhos derivados, devem ser preservados os avisos de copyright, licença e atribuição aplicáveis, conforme a licença. Alterações feitas em arquivos distribuídos devem ser identificadas. A licença **não exige** divulgar publicamente todo código derivado nem exibir o nome do autor em cada tela do programa.

**Autoria original:** `[NOME DO AUTOR OU ORGANIZAÇÃO]` — substitua antes da primeira publicação.
