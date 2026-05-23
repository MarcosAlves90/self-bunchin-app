# Bunchin App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115.x-009688?logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql)
![SQLite](https://img.shields.io/badge/SQLite-dev-003B57?logo=sqlite)
![License](https://img.shields.io/badge/license-Proprietary-red)

**Ponto eletrônico inteligente.** Registro de jornada, alocação em projetos e gestão de equipe com criptografia de dados sensíveis em nível de aplicação.

---

> [Overview](#overview) • [Features](#features) • [Tech Stack](#tech-stack) • [Architecture](#architecture) • [Project Structure](#project-structure) • [Quick Start](#quick-start) • [Commands](#commands) • [Environment Variables](#environment-variables) • [API](#api) • [Development](#development) • [Security](#security) • [Deployment](#deployment) • [Project Context](#project-context) • [License](#license)

---

## Overview

**Propósito:** Sistema de gerenciamento empresarial focado em registro de ponto eletrônico (punch clock), controle de jornada, alocação de funcionários em projetos e comunicação via e-mail transacional.

**Problema resolvido:** Empresas precisam centralizar o registro de ponto, acompanhamento de horas trabalhadas e alocação de equipe — tudo com privacidade de dados pessoais (PII) garantida por criptografia simétrica AES-GCM, sem expor dados sensíveis no banco.

**Arquitetura geral:** Monorepo dividido em backend FastAPI (API REST modular) e frontend Flutter (Clean Architecture por feature). Comunicação via HTTP JSON com autenticação por bearer token.

**Filosofia técnica:**

- Privacidade por design — PII criptografada antes de persistir
- Sem JWT — tokens aleatórios armazenados em hash permitem revogação individual
- UUID strings como PK — evita exposição de volume e facilita merge de ambientes
- Seed automático em dev — zero config para começar a desenvolver

---

## Features

| Capability | Descrição | Impacto Técnico |
|------------|-----------|-----------------|
| **Ponto eletrônico** | Registro de clock-in/out, break start/end com geolocalização opcional | Timestamp server-side, metadados criptografados |
| **Alocação em projetos** | Vínculo N:M entre funcionários e projetos | `employee_projects` junction table |
| **Gestão de funcionários** | CRUD com dados PII criptografados | Ciphertext + hash para lookup, unique por empresa |
| **Autenticação por bearer token** | Login com senha, sessão rastreável por hash | PBKDF2-SHA256 (310k iterações), revogação individual |
| **E-mail transacional** | Boas-vindas via Brevo API | Não bloqueante — falha não impacta fluxo principal |
| **HTTPS guard** | Middleware que bloqueia tráfego não seguro (exceto localhost) | Configurável via env var |
| **Seed automático** | Admin padrão criado se DB vazio | Controlado por `BUNCHIN_SEED_ON_STARTUP` |

---

## Tech Stack

### Backend

| Categoria | Tecnologia | Versão | Função |
|-----------|-----------|--------|--------|
| Runtime | Python | 3.12 | Linguagem |
| Framework | FastAPI | 0.115.x | API REST |
| ORM | SQLAlchemy | 2.0.x | Mapeamento objeto-relacional |
| Servidor | Uvicorn | 0.32.x | Servidor ASGI |
| Banco (dev) | SQLite | — | Desenvolvimento local |
| Banco (prod) | PostgreSQL | 15 | Produção |
| Driver DB | psycopg2-binary | 2.9.x | Conector PostgreSQL |
| Criptografia | cryptography | 44.x | AES-GCM para PII |
| Validação | email-validator | 2.2.x | Validação de e-mail |
| HTTP client | httpx | 0.28.x | Testes e chamadas externas |
| Testes | pytest | 8.3.x | Suite de testes |
| Env | python-dotenv | 1.0.x | Carregamento de `.env` |
| Fuso horário | tzdata | 2026.x | Timezone data |

### Frontend

| Categoria | Tecnologia | Versão | Função |
|-----------|-----------|--------|--------|
| Framework | Flutter | 3.x | UI multiplataforma |
| Linguagem | Dart | >=3.0 | Runtime |
| Geração de código | freezed | 3.2.x | Data classes imutáveis |
| Build runner | build_runner | 2.4.x | Geração de código |
| Localização | flutter_localizations | — | i18n |
| Geolocalização | geolocator | 14.x | Localização do dispositivo |
| HTTP | http | 1.2.x | Chamadas à API |
| Storage seguro | flutter_secure_storage | 9.2.x | Armazenamento de tokens |
| Fontes | google_fonts | 6.3.x | Tipografia |
| Ícones | cupertino_icons | 1.0.x | Ícones iOS |
| Lint | flutter_lints | 6.0.x | Análise estática |

---

## Architecture

### Backend — Modular Monolith + Clean Layers

```
┌─────────────────────────────────────────────────────┐
│                    FastAPI App                       │
│  ┌────────────┐  ┌────────────┐  ┌───────────────┐  │
│  │   Routes   │  │  Schemas   │  │   Services    │  │
│  │ (endpoints)│──│(Pydantic)  │──│(business logic)│  │
│  └────────────┘  └────────────┘  └───────┬───────┘  │
│                                          │          │
│  ┌───────────────────────────────────────▼────────┐ │
│  │              Models (SQLAlchemy)                │ │
│  └───────────────────────────────────────┬────────┘ │
│                                          │          │
│  ┌───────────────────────────────────────▼────────┐ │
│  │              Database (SQLite/PG)               │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

**Fluxo de request:**

1. Request HTTP → Uvicorn → FastAPI middleware stack (CORS, HTTPS guard, auth)
2. Rota → validação com schema Pydantic → serviço de domínio
3. Serviço → consulta/escreve via SQLAlchemy ORM (PII criptografada via `crypto.py`)
4. Resposta serializada → JSON response

### Frontend — Clean Architecture por Feature

```
lib/
  core/       │  camada base: config, network, storage, forms
  features/   │  módulos independentes (auth, admin, time_tracking, shared)
    auth/
      data/   │  DTOs, remote/local data sources
      domain/ │  entidades, repositórios (interfaces)
      presentation/ │  state management (BLoC), widgets, páginas
  contracts/  │  freezed data classes compartilhadas
  theme/      │  tema global
```

### Camadas de Dados

```
PII flow:
  Input → Services → crypto.encrypt() → ciphertext → DB
  DB → ciphertext → crypto.decrypt() → Services → Response

Auth flow:
  POST /login → valida senha (PBKDF2) → cria AuthSession
               → hash do token armazenado → retorna token plaintext
               → frontend salva em flutter_secure_storage
  Request autenticado → busca token do header → hash
                       → lookup em auth_sessions
                       → verifica expires_at, revoked_at
```

---

## Project Structure

```text
bunchin_flutter/
├── backend/
│   ├── app/
│   │   ├── main.py                # FastAPI app factory, middlewares, lifespan
│   │   ├── config.py              # Settings por env vars (BUNCHIN_*)
│   │   ├── models.py              # SQLAlchemy: Company, Employee, Project,
│   │   │                          #   EmployeeProject, UserAccount, Punch, AuthSession
│   │   ├── db.py                  # Engine, SessionLocal, Base, utcnow
│   │   ├── security.py            # PBKDF2-SHA256 hash/verify, token generation
│   │   ├── crypto.py              # AES-GCM encrypt/decrypt para PII
│   │   ├── errors.py              # DomainError com ErrorKind enum
│   │   ├── permissions.py         # RBAC: role-based access control
│   │   ├── authorization.py       # Auth middleware / Depends
│   │   ├── dependencies.py        # FastAPI DI: get_db, get_current_user
│   │   ├── seed.py                # Seed admin padrão se DB vazio
│   │   ├── api/
│   │   │   ├── router.py          # Agrega routers com prefixo /api/v1
│   │   │   └── routes/
│   │   │       ├── health.py      # GET /health
│   │   │       ├── auth.py        # POST /auth/login, /auth/logout
│   │   │       ├── employees.py   # CRUD /employees
│   │   │       ├── projects.py    # CRUD /projects
│   │   │       ├── time_clock.py  # POST /time-clock/punch
│   │   │       └── admin.py       # Endpoints administrativos
│   │   ├── schemas/               # Pydantic: auth, employee, project, punch, base
│   │   ├── services/              # Lógica: auth, brevo, employees, projects, time_clock
│   │   └── scripts/               # create_postgres.py, clean_postgres.py
│   ├── tests/                     # Pytest tests
│   ├── .env.example               # Template de env vars
│   ├── requirements.txt           # Dependências Python
│   ├── pytest.ini                 # Config do pytest
│   └── README.md                  # Docs backend
├── frontend/
│   ├── lib/
│   │   ├── main.dart              # Entry point Flutter
│   │   ├── contracts/             # Freezed: auth, employee, location, punch, time_clock
│   │   ├── core/
│   │   │   ├── config/            # Config da aplicação
│   │   │   ├── forms/             # Validação de formulários
│   │   │   ├── network/           # HTTP client + API chamadas
│   │   │   └── storage/           # Armazenamento local (secure storage)
│   │   ├── features/
│   │   │   ├── admin/             # Módulo admin
│   │   │   ├── auth/              # Módulo autenticação
│   │   │   ├── shared/            # Widgets e lógica compartilhada
│   │   │   └── time_tracking/     # Módulo de ponto eletrônico
│   │   └── theme/                 # Tema global (app_theme.dart)
│   ├── test/                      # Flutter tests
│   ├── pubspec.yaml               # Dependências Dart/Flutter
│   ├── analysis_options.yaml      # Lint rules
│   └── .metadata                  # Metadados Flutter
├── docs/                          # Documentação complementar
├── CONTEXT.md                     # Contexto compartilhado (humanos + IA)
├── CONTEXT-FORMAT.md              # Formato oficial do CONTEXT.md
├── README.md                      # Este arquivo
└── .gitignore
```

---

## Quick Start

### Pré-requisitos

- Python 3.12+
- Flutter SDK >=3.0
- Dart SDK >=3.0

### Backend

```bash
# 1. Entre na pasta
cd backend

# 2. Crie e ative ambiente virtual
python -m venv .venv
.venv\Scripts\activate    # Windows
# source .venv/bin/activate  # Linux/macOS

# 3. Instale dependências
pip install -r requirements.txt

# 4. Configure env vars (OBRIGATÓRIO: TOKEN_SECRET + ENCRYPTION_SECRET)
copy .env.example .env
# Edite .env com chaves reais

# 5. Execute
uvicorn app.main:app --reload
# API em http://localhost:8000
# Docs interativas em http://localhost:8000/docs
```

### Frontend

```bash
# 1. Entre na pasta
cd frontend

# 2. Instale dependências
flutter pub get

# 3. Gere classes freezed (necessário se alterar contracts/)
dart run build_runner build

# 4. Execute
flutter run -d web-server
# Ou via VS Code: Terminal > Run Task > frontend-web-server
```

### VS Code (recomendado)

```bash
Terminal > Run Task...
├── start-all            # Backend + frontend em paralelo
├── backend              # Apenas backend
└── frontend-web-server  # Apenas frontend
```

Tasks definidas em `.vscode/tasks.json`.

---

## Commands

### Backend

| Comando | Descrição |
|---------|-----------|
| `uvicorn app.main:app --reload` | Servidor dev com hot reload |
| `pytest` | Rodar testes |
| `pytest -v` | Testes verbose |
| `python -m app.scripts.create_postgres` | Criar DB PostgreSQL |
| `python -m app.scripts.clean_postgres` | Limpar DB PostgreSQL |

### Frontend

| Comando | Descrição |
|---------|-----------|
| `flutter pub get` | Instalar dependências |
| `dart run build_runner build` | Gerar freezed code |
| `flutter run -d web-server` | Dev server web |
| `flutter run` | Dev server (dispositivo conectado) |
| `flutter test` | Rodar testes |
| `flutter analyze` | Análise estática |
| `flutter build web` | Build produção web |
| `flutter build apk` | Build Android |
| `flutter build ios` | Build iOS |

---

## Environment Variables

Todas as variáveis prefixadas com `BUNCHIN_`. Template em `backend/.env.example`.

| Variável | Obrigatória | Descrição | Exemplo |
|----------|-------------|-----------|---------|
| `BUNCHIN_TOKEN_SECRET` | **Sim** | Chave secreta para geração de tokens | `a-long-random-token-secret` |
| `BUNCHIN_ENCRYPTION_SECRET` | **Sim** | Chave AES-256 para criptografia de PII | `a-different-long-random-encryption-secret` |
| `BUNCHIN_DATABASE_URL` | Não | URL do banco (default: SQLite) | `sqlite:///./bunchin.db` |
| `BUNCHIN_ALLOWED_ORIGINS` | Não | Origins permitidas no CORS | `http://localhost,http://localhost:3000` |
| `BUNCHIN_TIMEZONE` | Não | Timezone padrão | `America/Sao_Paulo` |
| `BUNCHIN_ENFORCE_HTTPS` | Não | Forçar HTTPS (exceto localhost) | `false` |
| `BUNCHIN_SEED_ON_STARTUP` | Não | Seed automático se DB vazio | `true` |
| `BUNCHIN_SEED_ADMIN_PASSWORD` | Não | Senha do admin no seed | `Bunchin@123` |
| `BUNCHIN_TOKEN_TTL_HOURS` | Não | Validade do token em horas | `12` |
| `BUNCHIN_REMEMBER_ME_TTL_DAYS` | Não | Validade do remember-me em dias | `30` |
| `BUNCHIN_BREVO_API_KEY` | Não | API key do Brevo | — |
| `BUNCHIN_BREVO_SENDER_EMAIL` | Não | E-mail remetente Brevo | — |
| `BUNCHIN_BREVO_SENDER_NAME` | Não | Nome remetente Brevo | `Bunchin` |
| `BUNCHIN_BREVO_WELCOME_ENABLED` | Não | Habilitar e-mail de boas-vindas | `true` |

---

## API

Base URL: `/api/v1`

### Rotas

| Método | Path | Descrição | Autenticação |
|--------|------|-----------|--------------|
| GET | `/health` | Health check | Não |
| POST | `/auth/login` | Login (email + password) | Não |
| POST | `/auth/logout` | Logout (revoga sessão) | Bearer |
| GET | `/employees` | Listar funcionários | Bearer (admin) |
| POST | `/employees` | Criar funcionário | Bearer (admin) |
| GET | `/employees/{id}` | Detalhes funcionário | Bearer |
| PUT | `/employees/{id}` | Atualizar funcionário | Bearer (admin) |
| DELETE | `/employees/{id}` | Remover funcionário | Bearer (admin) |
| GET | `/projects` | Listar projetos | Bearer |
| POST | `/projects` | Criar projeto | Bearer (admin) |
| GET | `/projects/{id}` | Detalhes projeto | Bearer |
| PUT | `/projects/{id}` | Atualizar projeto | Bearer (admin) |
| DELETE | `/projects/{id}` | Remover projeto | Bearer (admin) |
| POST | `/time-clock/punch` | Registrar ponto | Bearer |
| GET | `/admin/*` | Endpoints administrativos | Bearer (admin) |

### Formato de Erro

```json
{
  "detail": "Employee not found"
}
```

| HTTP Status | ErrorKind | Cenário |
|-------------|-----------|---------|
| 400 | `bad_request` | Dados inválidos |
| 401 | `unauthorized` | Token ausente/expirado |
| 403 | `forbidden` | Sem permissão |
| 404 | `not_found` | Recurso inexistente |
| 409 | `conflict` | Duplicidade (ex: email já cadastrado) |

---

## Development

### Convenções de Código

| Aspecto | Padrão |
|---------|--------|
| Python (backend) | snake_case funções/vars, PascalCase classes |
| Dart (frontend) | lowerCamelCase vars/funções, PascalCase classes/widgets |
| PKs | UUID v4 string (`str(uuid4())`) |
| PII fields | Sufixo `_ciphertext` (dados) / `_hash` (lookup) |
| Datas | Sempre `DateTime(timezone=True)` |
| Types | Evitar `dynamic` (Dart) e `Any` (Python) |
| Commits | [Conventional Commits](https://www.conventionalcommits.org/) |
| Lint backend | flake8 + pytest |
| Lint frontend | `flutter analyze` (flutter_lints) |

### Branching & Commits

```text
main        → produção
├── dev     → integração
    ├── feat/nome-da-feature
    ├── fix/nome-do-bug
    └── chore/nome-da-tarefa
```

Formato commit: `tipo(escopo): descrição` (ex: `feat(auth): add remember-me TTL`)

### Testing Strategy

- **Backend:** pytest com fixtures SQLAlchemy. Testes unitários para serviços, integração para rotas
- **Frontend:** flutter test com widgets tests. Freezed facilita teste de data classes
- Rodar `pytest` + `flutter test` antes de commitar

### Geração de Código

```bash
cd frontend
dart run build_runner build       # Gera .freezed.dart
dart run build_runner watch       # Modo watch durante desenvolvimento
```

---

## Security

| Aspecto | Implementação |
|---------|--------------|
| **Senhas** | PBKDF2-SHA256, 310.000 iterações, salt 16 bytes (`security.py`) |
| **Tokens** | `secrets.token_urlsafe(32)` com hash SHA-256 em `auth_sessions.token_hash` |
| **PII** | AES-256-GCM via lib `cryptography`. Chave em `BUNCHIN_ENCRYPTION_SECRET` |
| **CORS** | Liberado para origins locais. Regex valida `localhost` e `127.0.0.1` |
| **HTTPS** | Middleware `https_guard` bloqueia tráfego não seguro (exceto localhost) |
| **Secrets** | `BUNCHIN_TOKEN_SECRET` + `BUNCHIN_ENCRYPTION_SECRET` obrigatórios. App não inicia sem eles |
| **RBAC** | `permissions.py` define roles employee/admin |
| **Secure storage** | Tokens armazenados via `flutter_secure_storage` (Keychain/Keystore) |

---

## Performance

- **Indexação:** Campos de lookup (email_hash, cnpj_hash) indexados. Chaves estrangeiras indexadas
- **Criptografia:** Overhead apenas em campos PII. Campos não sensíveis (status, timestamps) em plaintext
- **DB:** SQLite em dev (sem configuração extra). PostgreSQL em prod
- **Migrações:** Atualmente sem migration tool — `SQLAlchemy.create_all()` recria schema a cada start. Pendente: Alembic

---

## Observability

- **Logs:** FastAPI loga requests automaticamente. `print` ocasional em serviços (pendente: logger estruturado)
- **Health check:** `GET /api/v1/health`
- **Métricas:** Não implementado (pendente)
- **Tracing:** Não implementado (pendente)

---

## Deployment

Atualmente sem configuração de CI/CD ou containerização (pendente). Ambientes documentados conceitualmente:

| Ambiente | DB | Acesso | Deploy |
|----------|----|--------|--------|
| **dev** | SQLite (`./bunchin.db`) | Equipe | Local (uvicorn --reload) |
| **staging** | PostgreSQL | QA | TBD |
| **prod** | PostgreSQL | Todos | TBD |

---

## Project Context

Este repositório mantém dois arquivos de contexto compartilhado:

| Arquivo | Função |
|---------|--------|
| [`CONTEXT.md`](./CONTEXT.md) | Fonte central de contexto do projeto (stack, arquitetura, ADRs, regras de negócio, glossário) |
| [`CONTEXT-FORMAT.md`](./CONTEXT-FORMAT.md) | Formato oficial que define a estrutura esperada do `CONTEXT.md` |

Ambos otimizados para leitura humana e consumo por agentes de IA.

---

## License

Proprietário. Uso interno. Código fechado.

---

*README gerado a partir do estado real do repositório em 2026-05-23. Consulte `CONTEXT.md` para contexto detalhado.*