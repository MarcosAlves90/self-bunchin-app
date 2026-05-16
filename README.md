# Bunchin App

Aplicativo de gerenciamento empresarial desenvolvido para facilitar a organização e controle de tarefas, projetos e equipes. O Bunchin App oferece uma interface intuitiva e recursos avançados para otimizar a produtividade e colaboração dentro das empresas.

## Execução local (VS Code)

Para iniciar backend e frontend pelo VS Code:

1. Abra o projeto na raiz.
2. Execute `Terminal > Run Task...`.
3. Selecione `start-all` para subir os dois serviços em paralelo.

Tasks disponíveis:

- `backend`: inicia a API FastAPI (`uvicorn app.main:app --reload`)
- `frontend-web-server`: inicia o Flutter em modo web server (`flutter run -d web-server`)
- `start-all`: inicia backend + frontend em paralelo

Os comandos oficiais ficam definidos em `.vscode/tasks.json`.