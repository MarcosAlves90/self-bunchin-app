# Backend Bunchin

API FastAPI + SQLAlchemy para autenticacao empresarial, administracao de funcionarios,
projetos e controle de ponto. Contratos HTTP usam `camelCase` para manter alinhamento
com o app Flutter.

## Visao Geral

- Base path: `/api/v1`
- Stack: FastAPI, SQLAlchemy, Pydantic, cryptography/Fernet, Passlib bcrypt
- Auth: bearer token opaco, armazenado como hash
- DB padrao: SQLite local; Postgres via `BUNCHIN_DATABASE_URL`
- Docs interativas: `http://127.0.0.1:8000/docs`

## Como Rodar

1. Crie env local:

```powershell
Copy-Item backend\.env.example backend\.env
```

2. Ajuste segredos obrigatorios em `backend\.env`:

```env
BUNCHIN_TOKEN_SECRET=troque-este-token-secret
BUNCHIN_ENCRYPTION_SECRET=troque-este-encryption-secret
```

3. Instale deps:

```powershell
cd backend
py -3 -m pip install -r requirements.txt
```

4. Suba API:

```powershell
py -3 -m uvicorn app.main:app --reload
```

5. Rode testes:

```powershell
py -3 -m pytest -q
```

## Config

Variaveis principais:

- `BUNCHIN_DATABASE_URL`: URL SQLAlchemy. Ex: `sqlite:///./bunchin.db`.
- `BUNCHIN_TOKEN_SECRET`: segredo para HMAC de tokens.
- `BUNCHIN_ENCRYPTION_SECRET`: segredo para criptografia/HMAC de PII.
- `BUNCHIN_SEED_ON_STARTUP`: cria seed dev quando `true`.
- `BUNCHIN_SEED_ADMIN_PASSWORD`: senha dos usuarios seed.
- `BUNCHIN_ENFORCE_HTTPS`: exige HTTPS fora de localhost quando `true`.
- `BUNCHIN_ALLOWED_ORIGINS`: CSV de origens CORS.
- `BUNCHIN_BREVO_API_KEY`: chave Brevo opcional.
- `BUNCHIN_BREVO_SENDER_EMAIL`: remetente Brevo opcional.
- `BUNCHIN_BREVO_WELCOME_ENABLED`: liga/desliga email de boas-vindas.

## Seed Dev

Com `BUNCHIN_SEED_ON_STARTUP=true`, startup cria empresa e usuarios:

| Role | Email | Senha |
| --- | --- | --- |
| admin | `marina.costa@bunchin.com` | `BUNCHIN_SEED_ADMIN_PASSWORD` |
| manager | `caio.martins@bunchin.com` | `BUNCHIN_SEED_ADMIN_PASSWORD` |
| employee | `joao.lima@bunchin.com` | `BUNCHIN_SEED_ADMIN_PASSWORD` |
| super_admin | `super.admin@bunchin.com` | `BUNCHIN_SEED_ADMIN_PASSWORD` |

## Auth

Login:

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "marina.costa@bunchin.com",
  "password": "BUNCHIN_SEED_ADMIN_PASSWORD",
  "keepConnected": true
}
```

Resposta inclui `accessToken`. Use em rotas protegidas:

```http
Authorization: Bearer <accessToken>
```

Sessao:

- Token nunca e salvo puro.
- DB guarda `token_hash`.
- `POST /api/v1/auth/logout` revoga sessao atual.
- `keepConnected=true` usa TTL longo configurado por `BUNCHIN_REMEMBER_ME_TTL_DAYS`.

## Permissoes

Permissoes ficam em `app/permissions.py`.

| Role | Permissoes principais |
| --- | --- |
| employee | auth context, projetos read, proprio ponto read/punch |
| manager | employee read/update, projetos create/update/assign, pontos manage |
| admin | manager + employee create/delete, projetos delete, company manage |
| super_admin | admin + admin cross-company |

Regra de escopo:

- Rotas comuns sao company-scoped.
- `admin.cross_company` exige `super_admin`.

## Endpoints

### Health

| Método | Rota | Auth |
| --- | --- | --- |
| GET | `/api/v1/health` | nao |

### Auth

| Método | Rota | Permissão |
| --- | --- | --- |
| POST | `/api/v1/auth/register-company` | publico |
| POST | `/api/v1/auth/login` | publico |
| GET | `/api/v1/auth/me` | `auth.read_context` |
| POST | `/api/v1/auth/logout` | token valido |

`register-company` agenda email Brevo de boas-vindas quando config Brevo existe.
Falha de email nao desfaz cadastro.

### Employees

| Método | Rota | Permissão |
| --- | --- | --- |
| GET | `/api/v1/employees` | `employees.read` |
| GET | `/api/v1/employees/{employeeId}` | `employees.read` |
| POST | `/api/v1/employees` | `employees.create` |
| PUT | `/api/v1/employees/{employeeId}` | `employees.update` |
| DELETE | `/api/v1/employees/{employeeId}` | `employees.delete` |
| GET | `/api/v1/employees/{employeeId}/projects` | `projects.read` |

Payload create/update:

```json
{
  "name": "Renata Souza",
  "role": "Analista Financeira",
  "department": "Financeiro",
  "email": "renata.souza@bunchin.com",
  "phone": "(11) 94444-6060",
  "unit": "Backoffice Centro",
  "expectedShiftStart": "08:00",
  "expectedShiftEnd": "17:00",
  "status": "active",
  "workMode": "hybrid",
  "roleLevel": "specialist",
  "requiresLocationOnPunch": false,
  "trustedDeviceRequired": true,
  "notes": "Observacao interna."
}
```

### Projects

| Metodo | Rota | Permissão |
| --- | --- | --- |
| GET | `/api/v1/projects` | `projects.read` |
| POST | `/api/v1/projects` | `projects.create` |
| GET | `/api/v1/projects/{projectId}` | `projects.read` |
| PUT | `/api/v1/projects/{projectId}` | `projects.update` |
| DELETE | `/api/v1/projects/{projectId}` | `projects.delete` |
| GET | `/api/v1/projects/{projectId}/members` | `projects.read` |
| POST | `/api/v1/projects/{projectId}/members` | `projects.assign` |
| DELETE | `/api/v1/projects/{projectId}/members/{employeeId}` | `projects.assign` |

`DELETE /projects/{projectId}` marca projeto como `inactive`; nao remove fisicamente.

Payload projeto:

```json
{
  "name": "Implantacao Cliente Sul",
  "description": "Projeto de operacao assistida.",
  "status": "active"
}
```

### Time Clock

| Método | Rota | Permissão |
| --- | --- | --- |
| GET | `/api/v1/time-clock/me` | `time_clock.read` |
| POST | `/api/v1/time-clock/me/punches` | `time_clock.punch` |
| GET | `/api/v1/time-clock/employees/{employeeId}/punches` | `time_clock.manage` |
| POST | `/api/v1/time-clock/employees/{employeeId}/punches` | `time_clock.manage` |
| PUT | `/api/v1/time-clock/employees/{employeeId}/punches/{punchId}` | `time_clock.manage` |
| DELETE | `/api/v1/time-clock/employees/{employeeId}/punches/{punchId}` | `time_clock.manage` |

Transições automáticas permitidas no ponto próprio:

- `checkedOut` -> `checkIn`
- `working` -> `breakStart` ou `checkOut`
- `onBreak` -> `breakEnd` ou `checkOut`

Se funcionario tem `requiresLocationOnPunch=true`, req deve enviar `location`.

Payload punch proprio:

```json
{
  "type": "checkIn",
  "projectId": null,
  "location": {
    "latitude": -23.5632,
    "longitude": -46.6545,
    "accuracyMeters": 12,
    "capturedAt": "2026-04-25T16:30:00-03:00"
  }
}
```

Payload ajuste gerencial:

```json
{
  "type": "checkIn",
  "timestamp": "2026-05-20T09:00:00-03:00",
  "detail": "Ajuste manual aprovado pelo gestor.",
  "projectId": null,
  "location": null
}
```

### Admin

| Metodo | Rota | Permissão |
| --- | --- | --- |
| GET | `/api/v1/admin/companies` | `admin.cross_company` global |

## Privacidade e Seguranca

PII protegida:

- Nome, email, telefone, CNPJ, unidade, cargo, departamento, notas: criptografados em repouso.
- Email e CNPJ: tambem possuem HMAC deterministico para lookup sem texto puro.
- localização do ponto: payload criptografado.
- Tokens: opacos, hash no banco.

Regras operacionais:

- Nao logar payload sensivel.
- Usar HTTPS fora de localhost em ambientes reais.
- Rotas sempre filtram por `company_id`, exceto rota global `super_admin`.
- Erros de dominio saem por `DomainError`; `main.py` traduz para HTTP.

## Arquitetura

Camadas:

- `app/api/routes`: HTTP, Depends, status codes.
- `app/services`: regras de negocio e persistencia. Nao importa FastAPI.
- `app/schemas`: contratos Pydantic em camelCase.
- `app/models`: modelos SQLAlchemy.
- `app/permissions.py`: matriz de roles/permissoes.
- `app/authorization.py`: checagem de permissão e escopo.
- `app/errors.py`: erros de dominio desacoplados de HTTP.
- `app/db.py`: engine, session, schema init e upgrades leves.

Teste arquitetural:

- `backend/tests/test_architecture.py` falha se `app/services` importar FastAPI.

## Schema e Upgrades

`init_database()` roda:

1. `Base.metadata.create_all()`
2. `upgrade_database_schema()`

`create_all()` nao altera tabelas existentes. Upgrades leves ficam em
`upgrade_database_schema()` para preservar dados locais, como adicao de
`punches.project_id`.

## Testes

Suite:

```powershell
cd backend
py -3 -m pytest -q
```

Coberturas principais:

- auth/login/logout/contexto
- permissão por role
- CRUD funcionarios
- projetos e membros
- ponto proprio e ponto gerencial
- criptografia de PII
- upgrades de schema
- regra arquitetural services sem FastAPI

## Troubleshooting

`psycopg2.errors.UndefinedColumn: column punches.project_id does not exist`

- Causa: DB Postgres existente sem coluna nova.
- Fix: reinicie API; `upgrade_database_schema()` aplica coluna no startup.

`401 Invalid or expired access token`

- Token expirado/revogado/invalido.
- Login novamente.

`403 Permission denied`

- Role sem permissão ou rota global chamada sem `super_admin`.

`400 HTTPS is required for non-local requests`

- `BUNCHIN_ENFORCE_HTTPS=true`.
- Use HTTPS ou localhost.
