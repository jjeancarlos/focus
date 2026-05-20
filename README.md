# Focus

<p align="center">
  <img src="./.docs/Samsung-Galaxy-S20-focus-cd64.onrender.com.png" alt="Tela inicial do Focus" width="320" />
</p>

<p align="center">
  <img src="./.docs/Samsung-Galaxy-S20-focus-cd64.onrender.com2.png" alt="Tela de missão do Focus" width="320" />
</p>

## Descrição

Focus é uma PWA inclusiva voltada para estudantes com dislexia e TDAH, desenvolvida para o 2º Hackathon SIF/UniRios 2026.

O sistema combina acessibilidade, gamificação e acompanhamento pedagógico para apoiar a aprendizagem de alunos e dar mais visibilidade aos professores sobre o progresso da turma.

## Funcionalidades atuais

### Aluno

- cadastro em múltiplas etapas
- login com autenticação por sessão
- seleção de perfil de acessibilidade (`dislexia`, `tdh`, `ambos`)
- missões de `leitura`, `foco` e `desafio`
- ganho de XP, níveis e sequência diária
- página de conquistas
- perfil com foto e vínculo com turma
- notificações e recados

### Professor

- dashboard com turmas
- criação e visualização de turmas
- busca por nome da turma e aluno no dashboard
- visualização individual do aluno
- gráficos semanais de desempenho
- envio de recados para turma e aluno
- remoção de aluno da turma sem excluir a conta
- exclusão de turma com desvinculação segura dos alunos
- geração de relatório em PDF com IA

## Stack

### Backend

- Ruby 3.4.8
- Rails 8.1.1
- PostgreSQL
- Puma
- Active Storage
- Solid Queue
- Solid Cache
- Solid Cable

### Frontend

- Tailwind CSS via `tailwindcss-rails`
- Turbo
- Propshaft
- Chartkick
- Chart.js

### Bibliotecas principais

- bcrypt
- pg
- groupdate
- dotenv-rails
- prawn
- prawn-table
- kamal

## Pré-requisitos

- Ruby 3.4.8
- Bundler
- PostgreSQL
- Redis opcional

## Configuração local

1. Instale as dependências:

```bash
bundle install
```

2. Crie o arquivo de ambiente:

```bash
cp .env.example .env
```

3. Preencha o `.env` com as variáveis necessárias:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=seu_usuario_postgres
DB_PASSWORD=sua_senha_postgres
DB_NAME_DEV=focus_development
DB_NAME_TEST=focus_test
GEMINI_API_KEY=sua_chave_do_gemini
```

Se sua aplicação depender de credentials criptografadas fora do ambiente local, você também pode definir:

```env
RAILS_MASTER_KEY=sua_master_key
```

Em ambiente local, isso normalmente não é necessário se o arquivo `config/master.key` já existir na máquina.

4. Prepare o banco:

```bash
bin/rails db:prepare
```

5. Carregue os dados de demonstração:

```bash
bin/rails db:seed
```

6. Inicie a aplicação:

```bash
bin/dev
```

A aplicação ficará disponível em `http://localhost:3000`.

## Seeds de demonstração

As seeds criam:

- professor demo
- turma padrão
- aluno demo
- atividades de leitura, foco e desafio

Credenciais padrão:

```txt
Professor
email: professor@focus.com
senha: focus123

Aluno
email: aluno@focus.com
senha: focus123

Código da turma
FOCUS2026
```

## Relatório com IA

A geração de relatório em PDF para professores depende da variável abaixo no ambiente:

```env
GEMINI_API_KEY=sua_chave_do_gemini
```

Sem essa chave, a funcionalidade de análise com IA não conseguirá consultar a API do Gemini.

## Execução com Docker Compose

O projeto possui ambiente de desenvolvimento com `compose.yml` e `Dockerfile.dev`.

1. Crie o arquivo de ambiente:

```bash
cp .env.example .env
```

2. Preencha ao menos estas variáveis:

```env
DB_USERNAME=seu_usuario
DB_PASSWORD=sua_senha
DB_NAME_DEV=focus_development
DB_NAME_TEST=focus_test
RAILS_MASTER_KEY=sua_master_key
```

3. Suba os containers:

```bash
docker compose up --build
```

A aplicação ficará disponível em `http://localhost:3000`.

## Estrutura funcional

- autenticação com `Current.session` e `Current.user`
- controllers enxutos com regras de negócio em `app/services`
- portal do aluno com missões e progresso
- portal do professor com gestão de turmas e acompanhamento individual
- PWA com manifesto e service worker

## Tipos de usuário

- `aluno`
- `professor`

## Modelo lógico do banco de dados

![Diagrama do modelo lógico](./.docs/modelo-logico-banco.png)
