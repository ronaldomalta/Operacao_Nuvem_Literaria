# Operação Nuvem Literária — LendoMais

Projeto React (Vite), API Express e PostgreSQL preparado para Docker Hub e Render.

## Arquitetura

- `frontend/`: React compilado e servido pelo Nginx, com fallback de rotas SPA.
- `backend/`: API Node.js/Express na porta `PORT` (padrão 3001).
- PostgreSQL: banco externo configurado por `DATABASE_URL` ou pelas variáveis `DB_*`.
- Frontend usa `VITE_API_URL` **em tempo de execução**, gerada no `config.js` ao iniciar o contêiner. Assim, a mesma imagem pode apontar para diferentes APIs sem rebuild.

## 1. Criar banco PostgreSQL

Crie uma instância PostgreSQL acessível pela API (no Render ou outro provedor). Copie a URL de conexão **privada/interna quando os serviços estiverem na mesma rede do provedor**, ou a URL externa quando necessário. A tabela `books` é criada automaticamente ao iniciar a API. Nunca publique credenciais no GitHub.

## 2. Criar e publicar as imagens no Docker Hub

No terminal, a partir da raiz do projeto, substitua `SEU_USUARIO` pelo usuário do Docker Hub:

```bash
docker login
docker build -t SEU_USUARIO/lendomais-backend:1.0 ./backend
docker build -t SEU_USUARIO/lendomais-frontend:1.0 ./frontend
docker push SEU_USUARIO/lendomais-backend:1.0
docker push SEU_USUARIO/lendomais-frontend:1.0
```

Deixe os dois repositórios públicos no Docker Hub para facilitar o uso no Render.

## 3. Publicar Backend no Render

1. No Render, crie um **Web Service** com origem **Existing Image / Docker image** (a nomenclatura pode variar).
2. Informe `docker.io/SEU_USUARIO/lendomais-backend:1.0`.
3. Configure `DATABASE_URL` com a URL do PostgreSQL e `PORT=3001` (ou ajuste conforme a plataforma). Se necessário, configure `DB_SSL` de acordo com o provedor de banco.
4. Aguarde o deploy e teste `https://SUA-API.onrender.com/health` e `https://SUA-API.onrender.com/api/books`.

## 4. Publicar Frontend no Render

1. Crie outro **Web Service** com **Existing Image / Docker image**.
2. Informe `docker.io/SEU_USUARIO/lendomais-frontend:1.0`.
3. Configure `VITE_API_URL=https://SUA-API.onrender.com/api` (**sem barra final**).
4. A imagem usa Nginx na porta **80**. Configure a porta do serviço para 80 se o Render solicitar e confirme a detecção de porta nos logs.
5. Abra a URL pública do frontend e teste listagem, criação, edição e exclusão de livros.

> A variável `VITE_API_URL` é inserida na inicialização do contêiner, não durante `npm run build`. Reinicie/reimplante o serviço após alterá-la.

## 5. Teste local opcional

```bash
# Terminal 1: execute a API com PostgreSQL configurado (ex.: backend/.env)
docker run --rm -p 3001:3001 --env-file backend/.env SEU_USUARIO/lendomais-backend:1.0

# Terminal 2: frontend consumindo a API local
docker run --rm -p 8080:80 -e VITE_API_URL=http://localhost:3001/api SEU_USUARIO/lendomais-frontend:1.0
```

Acesse `http://localhost:8080`. Para conectar o backend em contêiner a um PostgreSQL no host, `localhost` dentro do contêiner não aponta para o host; use endereço alcançável, rede Docker ou `host.docker.internal` quando disponível.

## Maior desafio técnico

O maior desafio técnico desta implantação é garantir que o Frontend React consiga acessar a API após sair do ambiente local. Em desenvolvimento, a aplicação usava `localhost`, mas esse endereço, no navegador de quem acessa o site, aponta para o próprio computador do visitante. Para resolver isso, foi implementada uma configuração da URL pública da API por variável de ambiente no contêiner do Nginx, sem depender de uma nova compilação do React. Também foi necessário adaptar a conexão PostgreSQL para aceitar `DATABASE_URL`, expor corretamente as portas dos serviços e configurar o Nginx para atender as rotas do frontend.

## Entrega (preencher após publicar)

- Docker Hub Frontend: `https://hub.docker.com/r/SEU_USUARIO/lendomais-frontend`
- Docker Hub Backend: `https://hub.docker.com/r/SEU_USUARIO/lendomais-backend`
- Frontend Render: `https://SEU-FRONTEND.onrender.com`
- Backend Render: `https://SUA-API.onrender.com`
- GitHub: `https://github.com/SEU_USUARIO/SEU_REPOSITORIO`

**Os endereços acima são modelos, não links publicados.** A publicação requer acesso às contas Docker Hub, Render e GitHub.
