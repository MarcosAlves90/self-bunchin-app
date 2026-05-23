# CONTEXT.md — Bunchin App

- Última atualização: 2026-05-23
- Versão do documento: 1.0.0
- Mantenedor: Time Platform

---

## 1. Visão Geral do Projeto

App de gerenciamento empresarial para registro de ponto eletrônico, controle de jornada e alocação de funcionários em projetos.

- **Público-alvo:** PMs, líderes de equipe, funcionários
- **Problema resolvido:** Centralizar registro de ponto, acompanhamento de horas e alocação de equipe em projetos com privacidade de dados (PII criptografada)
- **Links:** [docs](./docs), [frontend docs](./frontend), [backend docs](./backend)

---

## 2. Stack Tecnológica

| Tecnologia | Versão | Papel |
|------------|--------|-------|
| Flutter | 3.x | Frontend mobile/web |
| FastAPI | 0.115.x | API REST |
| SQLAlchemy | 2.0.x | ORM |
| SQLite | dev | Banco de dados local (dev) |
| PostgreSQL | 15.x | Banco de dados (prod/staging) |
| Uvicorn | 0.32.x | Servidor ASGI |
| Cryptography | 44.x | Criptografia de PII |
| Pytest | 8.3.x | Testes backend |
| Brevo API | — | Serviço de e-mail transacional |

---

## 3. Arquitetura

- **Frontend:** Clean Architecture (data/domain/presentation) por feature
- **Backend:** Modular monolith com FastAPI. Rotas organizadas por domínio (`api/routes/`), serviços em `services/`, schemas em `schemas/`
- **ORM:** SQLAlchemy declarativo com UUIDs string como PK
- **Criptografia:** PII armazenada ciphertext + hash para lookup. Criptografia simétrica via `cryptography` (AES-GCM)
- **Autenticação:** Bearer token com hash em `auth_sessions`. Senhas hash PBKDF2-SHA256 (310k iterações)

---

## 4. Estrutura de Pastas

```text
backend/
  app/
    main.py              # Factory do FastAPI, middlewares, lifespan
    config.py            # Settings via env vars (BUNCHIN_*)
    models.py            # SQLAlchemy models
    db.py                # Engine, session, base
    security.py          # Hash/verify password, token generation
    crypto.py            # PII encryption/decryption
    errors.py            # DomainError hierarchy
    permissions.py       # Role-based access control
    authorization.py     # Auth middleware/deps
    dependencies.py      # FastAPI dependency injection
    seed.py              # Database seeding
    api/
      router.py          # Agrega todas as rotas
      routes/            # Endpoints por domínio
    schemas/             # Pydantic schemas (auth, employee, project, punch, base)
    services/            # Lógica de negócio (auth, brevo, employees, projects, time_clock)
    scripts/             # Scripts utilitários (clean/create postgres)
  tests/                 # Testes backend
  .env.example           # Template de variáveis de ambiente

frontend/
  lib/
    main.dart            # Entry point
    contracts/           # Freezed data classes (auth, employee, location, punch, time_clock)
    core/
      config/            # App configuration
      forms/             # Form validation logic
      network/           # HTTP client, API calls
      storage/           # Local storage
    features/
      admin/             # Admin feature module
      auth/              # Authentication feature module
      shared/            # Shared widgets & logic
      time_tracking/     # Time tracking feature module
    theme/               # App theme
```

---

## 5. Convenções de Código

- **Backend:** Python snake_case para funções/vars, PascalCase para classes
- **Frontend:** Dart lowerCamelCase para variáveis/funções, PascalCase para classes/widgets
- **PKs:** UUID v4 strings (`str(uuid4())`)
- **PII fields:** Sufixo `_ciphertext` para dados criptografados, `_hash` para hashes de lookup
- **Datas:** Sempre datetime com timezone (`DateTime(timezone=True)`)
- **Commits:** Conventional Commits (feat/fix/chore/docs/test)
- **Linter:** analysis_options.yaml no frontend, pytest + flake8 no backend
- **Types:** Sem `dynamic` no Dart, sem `Any` no Python (exceto quando estritamente necessário)

---

## 6. Fluxos Críticos

### Autenticação
1. POST `/api/v1/auth/login` → valida email+senha → cria `AuthSession` → retorna bearer token
2. Token enviado via header `Authorization: Bearer <token>`
3. Middleware `authorization.py` verifica `token_hash` em `auth_sessions`
4. `expires_at` define validade. `revoked_at` permite logout manual
5. Refresh: novo login gera novo token. Não há refresh token dedicado

### Criação de Funcionário
1. Admin POST `/api/v1/employees` → dados PII criptografados (ciphertext) + hash para email
2. Employee vinculado a Company via `company_id`
3. Se `trusted_device_required` ou `requires_location_on_punch`, validações extras no frontend

### Registro de Ponto (Punch)
1. Employee POST `/api/v1/punches` com tipo (clock_in/clock_out/break_start/break_end)
2. `timestamp` registrado no servidor. `detail_ciphertext` armazena metadados
3. `location_payload_ciphertext` opcional se `requires_location_on_punch`
4. Vínculo opcional com `project_id` para alocação de horas

### HTTPS Guard
- Middleware `https_guard` em `main.py` rejeita requests não-HTTPS (exceto localhost) quando `BUNCHIN_ENFORCE_HTTPS=true`

---

## 7. Decisões Arquiteturais (ADR)

### ADR-001: Criptografia de PII em nível de aplicação

- **Data:** 2026-05-23
- **Contexto:** Dados pessoais (nome, email, CPF, CNPJ) não podem ficar em plaintext no DB
- **Decisão:** Criptografia simétrica AES-GCM via lib `cryptography`. Cada campo sensível armazenado como `_ciphertext`. Campo `_hash` (SHA-256) para busca indexada
- **Alternativas:** PostgreSQL pgcrypto (acoplamento com DB), hashing apenas (sem capacidade de descriptografar)
- **Consequências:** Lookups só por hash. Descriptografia overhead. Nova chave de criptografia exige re-criptografia de todos os registros

### ADR-002: Autenticação stateless com bearer token

- **Data:** 2026-05-23
- **Contexto:** Necessário controle de sessão ativa (revogação)
- **Decisão:** Token aleatório armazenado hash em `auth_sessions`. Não é JWT. Permite revogação individual e controle de expiração
- **Alternativas:** JWT (sem revogação), OAuth2 completo (overkill)
- **Consequências:** Lookup em DB a cada request. Mais simples que JWT para revogação. `remember_me` estende TTL para 30 dias

### ADR-003: UUID string como PK

- **Data:** 2026-05-23
- **Contexto:** Evitar exposição de IDs sequenciais e facilitar merge entre ambientes
- **Decisão:** UUID v4 como string (36 chars) em vez de tipo UUID nativo
- **Alternativas:** Int auto-increment (expõe volume), UUID binário (menos legível)
- **Consequências:** Indexação 4x maior que int. Sem exposição de ordenação. Compatível com SQLite e PostgreSQL

---

## 8. Segurança

- **Senhas:** PBKDF2-SHA256 com 310.000 iterações + salt de 16 bytes (`security.py`)
- **Tokens:** `secrets.token_urlsafe(32)` com hash SHA-256 armazenado em `auth_sessions.token_hash`
- **PII:** AES-GCM com chave de 256 bits via `cryptography` lib. Configurado via `BUNCHIN_ENCRYPTION_SECRET`
- **CORS:** Liberado para origins locais + configurável via `BUNCHIN_ALLOWED_ORIGINS`. Regex `^https?://(localhost|127\.0\.0\.1)(:\d+)?$`
- **HTTPS:** Middleware `https_guard` bloqueia tráfego não seguro (configurável via `BUNCHIN_ENFORCE_HTTPS`)
- **Secrets:** `BUNCHIN_TOKEN_SECRET` e `BUNCHIN_ENCRYPTION_SECRET` são obrigatórios. App não inicia sem eles
- **Role-based access:** `permissions.py` define RBAC básico (employee/admin)

---

## 9. Ambientes

| Ambiente | URL | DB | Acesso | Deploy automático |
|----------|-----|----|--------|-------------------|
| dev | `http://localhost:8000` | SQLite (`./bunchin.db`) | equipe | — |
| staging | TBD | PostgreSQL | QA | TBD |
| prod | TBD | PostgreSQL | todos | TBD |

---

## 10. Integrações Externas

### Brevo (Sendinblue) — E-mail transacional

- **API Key:** `BUNCHIN_BREVO_API_KEY` (secret, nunca em código)
- **Sender:** Configurável via `BUNCHIN_BREVO_SENDER_EMAIL` / `BUNCHIN_BREVO_SENDER_NAME`
- **Funcionalidade:** Envio de e-mail de boas-vindas (controlado por `BUNCHIN_BREVO_WELCOME_ENABLED`)
- **Serviço:** `services/brevo.py`
- **Comportamento em falha:** Log de erro, não bloqueia fluxo principal

---

## 11. Padrões de API

- **Prefixo:** `/api/v1`
- **Formato:** JSON. `Content-Type: application/json`
- **Erros:** `{"detail": "mensagem"}` com HTTP status codes mapeados por `ErrorKind`:
  - `bad_request` → 400
  - `unauthorized` → 401
  - `forbidden` → 403
  - `not_found` → 404
  - `conflict` → 409
- **Autenticação:** Header `Authorization: Bearer <token>`
- **Paginação:** TBD (cursor ou offset ainda não definido)

---

## 12. Regras de Negócio

- **Empresa (Company):** CNPJ único por hash. Consentimento obrigatório (`consented_at`). Timezone configurável
- **Funcionário (Employee):** Email único por empresa (`uq_employee_email_per_company`). Status, work_mode, role_level definidos. `pending_adjustments` rastreia correções pendentes
- **Ponto (Punch):** Tipos: clock_in/clock_out/break_start/break_end. Timestamp no servidor (não confia no client). Vinculação opcional a projeto
- **Projeto (Project):** Status indexado. Employee-projeto via N:M (`employee_projects`). Exclusão de funcionário remove vínculo
- **Sessão (AuthSession):** `expires_at` define validade. `revoked_at` para logout. `remember_me` estende TTL de 12h para 30 dias
- **Seed:** Admin padrão criado se DB vazio (controlado por `BUNCHIN_SEED_ON_STARTUP`). Senha configurável via `BUNCHIN_SEED_ADMIN_PASSWORD`

---

## 13. Observações para IA

- **Arquivos gerados:** `*.freezed.dart` não devem ser editados manualmente. Sempre editar o `.dart` base e rodar `dart run build_runner build`
- **Secrets:** `BUNCHIN_TOKEN_SECRET` e `BUNCHIN_ENCRYPTION_SECRET` nunca devem ser commitados. Usar `.env.example` como template
- **Commits:** Seguir Conventional Commits. `feat:`, `fix:`, `chore:`, `docs:`, `test:`
- **Testes:** Rodar `pytest` no backend e `flutter test` no frontend antes de commitar
- **DB migrations:** Atualmente sem migration tool (SQLAlchemy `create_all`). Se adicionar migration, nunca alterar migrations já aplicadas
- **`CONTEXT.md`:** Manter atualizado. Se uma regra de negócio mudar, atualizar este arquivo primeiro

---

## 14. Pendências Técnicas (Tech Debt)

- [ ] Adicionar migration tool (Alembic) para controle de schema evolution
- [ ] Definir padrão de paginação em listas de employees/punches/projects
- [ ] Implementar refresh token dedicado (atualmente só novo login)
- [ ] Adicionar rate limiting em endpoints de login
- [ ] Adicionar testes de integração para fluxos críticos
- [ ] Avaliar necessidade de containerização (Dockerfile + docker-compose)

---

## 15. Glossário

| Termo | Definição |
|-------|-----------|
| Bunchin | Nome do app (jogo de palavras com "bunch" + "punch clock") |
| Punch | Registro de ponto (bater ponto) |
| Company | Empresa cliente que usa o sistema |
| Employee | Funcionário vinculado a uma empresa |
| UserAccount | Conta de acesso (login) do funcionário/admin |
| PII | Personally Identifiable Information (dados pessoais sensíveis) |
| Ciphertext | Texto criptografado armazenado no banco |
| Hash | SHA-256 para lookup único (ex: email_hash, cnpj_hash) |
| Brevo | Plataforma de e-mail transacional (ex-Sendinblue) |
| Workspace | Espaço de trabalho com projetos e membros |
| Bunch | Agrupamento de tarefas relacionadas |