# Brevo no backend

Integracao minima, focada em nao complicar o fluxo atual.

## O que foi ligado

- disparo de e-mail transacional de boas-vindas apos `POST /api/v1/auth/register-company`
- envio opcional: se Brevo nao estiver configurado, o cadastro continua normal e nenhum e-mail e enviado
- sem persistencia extra de PII no banco e sem log de payload sensivel

## Variaveis de ambiente

Adicione no `backend/.env`:

```env
BUNCHIN_BREVO_API_KEY=seu-api-key-brevo
BUNCHIN_BREVO_SENDER_EMAIL=remetente-validado@seudominio.com
BUNCHIN_BREVO_SENDER_NAME=Bunchin
BUNCHIN_BREVO_WELCOME_ENABLED=true
```

## Comportamento atual

- o backend chama a API transacional da Brevo em `https://api.brevo.com/v3/smtp/email`
- o remetente precisa existir e estar validado na sua conta Brevo
- o conteudo do e-mail esta inline no backend para manter a integracao simples por enquanto
- se a Brevo falhar, o cadastro da empresa nao e revertido

## Proximo passo natural

Quando voce quiser evoluir isso, o primeiro passo coerente e trocar o HTML inline por `templateId` da propria Brevo. O ponto de integracao ja ficou isolado em `app/services/brevo.py`.
