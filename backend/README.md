# Backend Bunchin

Backend em FastAPI + SQLAlchemy alinhado aos contratos de dados ja definidos no Flutter:

- autenticacao empresarial
- cadastro de funcionarios
- ponto com batidas geolocalizadas

## Principios aplicados

- PII criptografado em repouso com `cryptography.Fernet`
- tokens opacos no lugar de JWT para reduzir superficie de exposicao
- hashes deterministas para busca de email e CNPJ sem armazenar texto puro
- middleware opcional para exigir HTTPS fora de localhost
- sem log de payload sensivel por padrao

## Como executar

1. Crie um arquivo `.env` a partir de `.env.example`.
2. Instale dependencias:

```bash
pip install -r requirements.txt
```

3. Suba a API:

```bash
uvicorn app.main:app --reload
```

Documentacao interativa:

- `http://127.0.0.1:8000/docs`

## Seed de desenvolvimento

Quando `BUNCHIN_SEED_ON_STARTUP=true`, o backend cria uma empresa e um usuario admin de exemplo:

- email: `marina.costa@bunchin.com`
- senha: valor de `BUNCHIN_SEED_ADMIN_PASSWORD`

Esse seed replica os perfis e estados usados hoje nas telas do frontend.

## Endpoints principais

- `POST /api/v1/auth/register-company`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`
- `GET /api/v1/employees`
- `GET /api/v1/employees/{employeeId}`
- `POST /api/v1/employees`
- `PUT /api/v1/employees/{employeeId}`
- `GET /api/v1/time-clock/me`
- `POST /api/v1/time-clock/me/punches`

## Observacoes

- O campo `trustedDeviceRequired` e persistido, mas ainda nao e bloqueado no backend porque o frontend atual nao envia um contrato de dispositivo confiavel. Mantive o design simples e sem overengineering ate existir esse sinal.
- O backend devolve campos em `camelCase` para bater com os contratos atuais do Flutter.
