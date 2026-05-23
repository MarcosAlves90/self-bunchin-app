# CONTEXT-FORMAT.md — Formato Oficial do CONTEXT.md

> Este arquivo define a estrutura padronizada do `CONTEXT.md`, fonte central de contexto compartilhado entre humanos e agentes de IA.  
> Todo conteúdo novo ou atualizado no `CONTEXT.md` DEVE seguir este formato.

---

## 1. Propósito

`CONTEXT.md` documenta informações críticas do projeto para:

- Alinhar equipe e agentes de IA sobre o estado atual do sistema
- Reduzir ambiguidade em decisões técnicas
- Acelerar onboarding de novos contribuidores
- Servir como fonte única de verdade para regras, padrões e arquitetura

---

## 2. Princípios de Redação

| Princípio | Descrição |
|-----------|-----------|
| **Clareza** | Frases curtas. Termo técnico exato. Sem jargão vago. |
| **Baixa redundância** | Cada informação aparece uma vez. Use referências cruzadas. |
| **Escaneabilidade** | Títulos, listas, tabelas, blocos de código. Leitura vertical. |
| **Facilidade de manutenção** | Seções curtas. Datas em decisões. Arquivos pequenos = fáceis de atualizar. |
| **Compatibilidade com IA** | Markdown simples. Hierarquia clara. Sem formatação complexa (HTML, spans). |

---

## 3. Estrutura Obrigatória do `CONTEXT.md`

```
# CONTEXT.md — [Nome do Projeto]

<!-- Metadados -->
- Última atualização: YYYY-MM-DD
- Versão do documento: X.Y.Z
- Mantenedor: [time/pessoa responsável]

---

## 1. Visão Geral do Projeto

**Propósito:** Resumo executivo do projeto. O que faz, para quem, por que existe.

- Descrição (2-3 frases)
- Público-alvo
- Problema resolvido
- Links úteis (docs, design system, ambiente de staging)

---

## 2. Stack Tecnológica

**Propósito:** Lista de tecnologias, versões e papéis no sistema.

| Tecnologia | Versão | Papel |
|------------|--------|-------|
| Flutter    | 3.x    | Frontend mobile/web |
| FastAPI    | 0.x    | API REST |
| PostgreSQL | 15.x   | Banco de dados |

---

## 3. Arquitetura

**Propósito:** Visão macro da arquitetura. Diagramas textuais, padrões, fluxos de dados.

- Padrão arquitetural (ex: Clean Architecture, MVC, Modular Monolith)
- Diagrama em Mermaid (se aplicável)
- Relações entre camadas
- Regras de comunicação entre módulos

---

## 4. Estrutura de Pastas

**Propósito:** Mapa da árvore de diretórios com explicação do papel de cada pasta-chave.

```text
frontend/lib/
  core/           # Código compartilhado: temas, utils, constantes
  features/       # Módulos por funcionalidade (Clean Architecture)
  shared/         # Widgets e lógica compartilhada entre features
```

---

## 5. Convenções de Código

**Propósito:** Regras que todo código do projeto deve seguir.

- Estilo de nomenclatura (camelCase, snake_case, PascalCase)
- Organização de imports
- Tamanho máximo de função/arquivo
- Uso de types vs dynamic
- Padrão de commits (Conventional Commits)
- Linters e formatadores configurados

---

## 6. Fluxos Críticos

**Propósito:** Sequência de passos para operações essenciais do sistema.

- Autenticação: fluxo de login, refresh token, logout
- Criação de [recurso X]: validações, regras de negócio, side effects
- Integração com serviço Y]: request, retry, fallback

Formato:

```text
1. [Ação] -> [Condição] -> [Resultado esperado]
2. [Erro comum] -> [Manifestação] -> [Solução conhecida]
```

---

## 7. Decisões Arquiteturais (ADR)

**Propósito:** Registro de decisões técnicas importantes com contexto, alternativa e consequência.

Cada ADR segue:

```markdown
### ADR-001: [Título da Decisão]

- **Data:** YYYY-MM-DD
- **Contexto:** Por que a decisão foi necessária
- **Decisão:** O que foi escolhido
- **Alternativas:** O que foi rejeitado e por que
- **Consequências:** Impactos positivos e negativos previstos
```

---

## 8. Segurança

**Propósito:** Diretrizes de segurança, proteção de dados, prevenção de vulnerabilidades.

- Autenticação e autorização (JWT, OAuth, RBAC)
- Proteção de secrets (variáveis de ambiente, vault)
- Validação de entrada (sanitização, rate limiting)
- Headers de segurança (CSP, CORS, HSTS)

---

## 9. Ambientes

**Propósito:** Descrição de cada ambiente de deploy e suas diferenças.

| Ambiente | URL | DB | Acesso | Deploy automático |
|----------|-----|----|--------|-------------------|
| dev      | ... | ... | equipe | push em main |
| staging  | ... | ... | QA | tag release |
| prod     | ... | ... | todos | aprovação manual |

---

## 10. Integrações Externas

**Propósito:** Serviços de terceiros que o sistema consome.

- Nome do serviço
- API versionada
- Chave de autenticação (referência a secret, nunca valor literal)
- Rate limits
- Endpoints críticos
- Comportamento em falha (timeout, retry, fallback)

---

## 11. Padrões de API

**Propósito:** Contrato de como as APIs são projetadas e documentadas.

- Prefixo de URL (/api/v1)
- Formato de request/response (JSON, HTTP codes)
- Paginação (cursor vs offset)
- Versionamento
- Padrão de erros (código, mensagem, traceId)

---

## 12. Regras de Negócio

**Propósito:** Lógica de domínio que não pode ser inferida do código sozinha.

- Regras de validação
- Cálculos ou fórmulas específicas
- Estados e transições permitidas
- Políticas de acesso

---

## 13. Observações para IA

**Propósito:** Instruções explícitas para agentes de IA que forem editar ou analisar o código.

- Quais arquivos nunca devem ser alterados manualmente (ex: gerados)
- Padrões de prompt ou contexto esperados
- Comandos frequentes (testar, buildar, rodar)
- Sensibilidades (não commitar secrets, não alterar migrations)

---

## 14. Pendências Técnicas (Tech Debt)

**Propósito:** Itens conhecidos que precisam de refatoração ou melhoria futura.

- [ ] Descrição do débito
- Impacto estimado
- Solução proposta
- Prioridade (baixa/média/alta)

---

## 15. Glossário

**Propósito:** Definição de termos específicos do domínio.

| Termo | Definição |
|-------|-----------|
| Workspace | Espaço de trabalho com projetos e membros |
| Bunch | Agrupamento de tarefas relacionadas |

---

## 4. Regras de Manutenção

1. **Atualização contínua** — CONTEXT.md reflete o estado atual. Desatualizado = perigoso.
2. **Uma fonte de verdade** — Se a informação está em CONTEXT.md, ela vale. Remova duplicatas em outros lugares.
3. **Seções opcionais** — Se uma seção não se aplica, remova-a em vez de deixá-la vazia.
4. **Datas em tudo** — Toda entrada com data. Facilita rastrear obsolescência.
5. **Tamanho** — Prefira arquivo único até ~500 linhas. Depois disso, divida em `docs/context/` com índice.
6. **Reviews** — Mudanças no CONTEXT.md passam pelo mesmo processo de PR que código.

---

## 5. Exemplo de Uso

```markdown
# CONTEXT.md — Bunchin App

- Última atualização: 2026-05-23
- Versão: 1.0.0
- Mantenedor: Time Platform

---

## 1. Visão Geral do Projeto

App de gerenciamento empresarial para organização de tarefas, projetos e equipes.
Público: PMs e líderes de equipe.
Problema: centralizar acompanhamento de entregas.
Links: [docs](./docs), [staging](https://staging.bunchin.app)

---
```

---

## 6. Checklist de Qualidade

Antes de commitar alterações no `CONTEXT.md`, verifique:

- [ ] Informações técnicas estão corretas e atuais?
- [ ] Links funcionam?
- [ ] Seções obrigatórias preenchidas?
- [ ] Sem duplicação com outros arquivos de documentação?
- [ ] Linguagem objetiva, sem rodeios?
- [ ] Agente de IA consegue extrair respostas sem ambiguidade?