# Bunchin App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115.x-009688?logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql)
![SQLite](https://img.shields.io/badge/SQLite-dev-003B57?logo=sqlite)
![License](https://img.shields.io/badge/license-Proprietary-red)

Ponto eletrônico e gestão de equipe com criptografia de dados sensíveis em nível de aplicação.

---

> [Visão Geral](#visão-geral) • [Recursos](#recursos) • [Stack](#stack) • [Arquitetura](#arquitetura) • [Estrutura](#estrutura) • [Início Rápido](#início-rápido) • [Comandos](#comandos) • [Variáveis de Ambiente](#variáveis-de-ambiente) • [API](#api) • [Segurança](#segurança) • [Projeto Atual](#projeto-atual) • [Licença](#licença)

---

## Visão Geral

O Bunchin App é um sistema de gerenciamento empresarial focado em registro de ponto eletrônico, controle de jornada, alocação de funcionários em projetos e comunicação por e-mail transacional.

Ele foi desenhado para manter dados pessoais sensíveis protegidos por criptografia simétrica AES-GCM antes da persistência. A autenticação usa token aleatório armazenado em hash, o que permite revogação individual sem depender de JWT.

O repositório é um monorepo com:

- Backend em FastAPI
- Frontend em Flutter
- Documentação compartilhada em `CONTEXT.md`

---

## Recursos

| Recurso | Descrição | Observação |
|---|---|---|
| Ponto eletrônico | Clock-in, clock-out, pausa e retorno | Timestamp gerado no servidor |
| Gestão de equipe | CRUD de funcionários e regras de operação | Dados PII criptografados |
| Projetos | Vínculo N:1 e N:N para alocação de equipe | Status e políticas separadas |
| Autenticação | Login com sessão rastreável | Token aleatório com hash |
| Tema global | Tema claro, escuro e seguir sistema | Persistido no dispositivo |
| Configurações | Tela global de aparência | Acesso pelo workspace |
| E-mail transacional | Envio via Brevo | Falha não bloqueia o fluxo principal |
| Seed automático | Criação de admin padrão em dev | Controlado por variável de ambiente |

---

## Stack

### Backend

| Tecnologia | Versão | Função |
|---|---:|---|
| Python | 3.12 | Linguagem principal |
| FastAPI | 0.115.x | API REST |
| SQLAlchemy | 2.0.x | ORM |
| SQLite | dev | Banco local |
| PostgreSQL | 15.x | Banco de produção/staging |
| Uvicorn | 0.32.x | Servidor ASGI |
| Cryptography | 44.x | Criptografia AES-GCM |
| Pytest | 8.3.x | Testes |
| Brevo API | — | E-mail transacional |

### Frontend

| Tecnologia | Versão | Função |
|---|---:|---|
| Flutter | 3.x | UI mobile/web |
| Dart | >=3.0 | Linguagem |
| Freezed | 3.2.x | Modelos imutáveis |
| Build Runner | 2.4.x | Geração de código |
| Flutter Localizations | — | Localização pt-BR |
| Geolocator | 14.x | Geolocalização |
| HTTP | 1.2.x | Cliente HTTP |
| Flutter Secure Storage | 9.2.x | Armazenamento seguro |
| Google Fonts | 6.3.x | Tipografia |
| Flutter Lints | 6.0.x | Análise estática |

---

## Arquitetura

### Backend

O backend segue um modular monolith com camadas limpas:

- `api/routes/` expõe os endpoints
- `schemas/` define contratos de entrada e saída
- `services/` concentra a lógica de negócio
- `domain/` guarda regras de domínio reutilizáveis
- `events/` centraliza eventos de domínio e seus handlers

### Frontend

O frontend usa Clean Architecture por feature, com módulos independentes para:

- `auth`
- `admin`
- `settings`
- `time_tracking`
- `shared`

O tema visual é global e é controlado por um `ThemeModeController` com persistência em `flutter_secure_storage`.

---

## Estrutura

```text
backend/
  app/
    api/
      router.py
      routes/
    domain/
    events/
    schemas/
    services/
    main.py
    models.py
    security.py
    crypto.py
    permissions.py
    authorization.py
    dependencies.py
    seed.py
    scripts/
  tests/
  README.md
  requirements.txt
  pytest.ini

frontend/
  lib/
    main.dart
    contracts/
    core/
      config/
      forms/
      network/
      storage/
      theme/
    features/
      admin/
      auth/
      settings/
      shared/
      time_tracking/
    theme/
  test/
  pubspec.yaml
```

---

## Início Rápido

### Backend

```bash
cd backend
python -m venv .venv
.venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

### Frontend

```bash
cd frontend
flutter pub get
dart run build_runner build
flutter run -d web-server
```

---

## Comandos

### Backend

```bash
pytest
uvicorn app.main:app --reload
python -m app.scripts.create_postgres
python -m app.scripts.clean_postgres
```

### Frontend

```bash
flutter test
dart run build_runner build
dart format lib test
```

---

## Variáveis de Ambiente

| Variável | Função |
|---|---|
| `BUNCHIN_TOKEN_SECRET` | Secret obrigatório para tokens |
| `BUNCHIN_ENCRYPTION_SECRET` | Secret obrigatório para PII |
| `BUNCHIN_ALLOWED_ORIGINS` | Origens liberadas para CORS |
| `BUNCHIN_ENFORCE_HTTPS` | Ativa o guard de HTTPS |
| `BUNCHIN_SEED_ON_STARTUP` | Cria admin padrão em ambiente vazio |
| `BUNCHIN_SEED_ADMIN_PASSWORD` | Senha do admin seed |
| `BUNCHIN_BREVO_API_KEY` | Chave da API Brevo |
| `BUNCHIN_BREVO_SENDER_EMAIL` | E-mail remetente |
| `BUNCHIN_BREVO_SENDER_NAME` | Nome do remetente |
| `BUNCHIN_BREVO_WELCOME_ENABLED` | Ativa e-mail de boas-vindas |

---

## API

- Prefixo: `/api/v1`
- Formato: JSON
- Autenticação: `Authorization: Bearer <token>`
- Erros: `{"detail":"mensagem"}`
- Recursos principais:
  - `/auth/login`
  - `/auth/logout`
  - `/employees`
  - `/projects`
  - `/time-clock`
  - `/admin`

---

## Segurança

- PII criptografada com AES-GCM antes de persistir
- Tokens gerados de forma aleatória e armazenados em hash
- Senhas com PBKDF2-SHA256
- CORS configurável por ambiente
- Middleware de HTTPS em ambiente não local
- Secrets obrigatórios via variáveis de ambiente

---

## Projeto Atual

Estado atual do frontend:

- Tema global com três modos: claro, escuro e seguir sistema
- Tela de configurações para alternar o tema
- `admin_employees_page.dart` dividido em arquivo principal e widgets auxiliares
- Módulo de auth simplificado com widgets comuns de formulário
- Login sem botão de Google

Estado atual do backend:

- Monólito modular com rotas por domínio
- Camada `domain/` para regras compartilhadas
- Camada `events/` para eventos e handlers de domínio
- Endpoints para auth, employees, projects, time clock, admin e health

---

## Licença

Uso proprietário. Consulte o repositório ou o time responsável para detalhes de distribuição.
