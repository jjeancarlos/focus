# Focus

## Descrição do projeto

Focus é uma PWA inclusiva voltada para estudantes com dislexia e TDAH, desenvolvida para o 2º Hackathon SIF/UniRios 2026.

O projeto busca tornar o processo de aprendizagem mais acessível, interativo e motivador por meio de missões educacionais adaptadas ao perfil de acessibilidade do aluno.

Problemas que o software se propõe a resolver:

- dificuldade de manter foco e constância nos estudos
- baixa adaptação de atividades para estudantes com dislexia e TDAH
- falta de acompanhamento visual de progresso, nível, XP e sequência de prática
- necessidade de uma experiência de aprendizado mais inclusiva, positiva e responsiva

## Tecnologias utilizadas e versões

### Backend

- Ruby 3.4.8
- Rails 8.1.3
- PostgreSQL
- Puma
- Active Storage
- Solid Queue
- Solid Cache
- Solid Cable

### Frontend

- Tailwind CSS
- Stimulus
- Turbo
- Importmap

### Bibliotecas e ferramentas principais

- bcrypt 3.1.22
- pg 1.6.3
- chartkick 5.2.1
- groupdate 6.8.0
- kamal 2.11.0
- Bundler 4.0.3

### Ambiente e execução

- Foreman
- Docker
- Docker Compose
- dotenv

## Abordagens e metodologias utilizadas

- desenvolvimento web com Ruby on Rails seguindo padrão MVC
- separação de regras de negócio em service objects
- uso de acessibilidade como requisito central de produto
- gamificação com XP, níveis e sequência diária para incentivo ao aprendizado
- interface pensada para inclusão de estudantes com dislexia e TDAH
- arquitetura com controllers enxutos e lógica de negócio desacoplada
- uso de PWA para facilitar acesso multiplataforma

## Como executar o projeto

### Pré-requisitos

- Ruby 3.4.8
- Bundler 4.0.3
- PostgreSQL
- Node.js
- Yarn
- Foreman
- Docker
- Docker Compose

### Configuração inicial

```bash
bundle install
cp .env.example .env
```

Preencha o arquivo `.env` com as variáveis necessárias:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=seu_usuario
DB_PASSWORD=sua_senha
DB_NAME_DEV=focus_development
DB_NAME_TEST=focus_test
```

### Banco de dados

```bash
bin/rails db:prepare
```

### Executar em desenvolvimento

```bash
bin/dev
```

Ou com Foreman:

```bash
foreman start -f Procfile.dev
```

### Acesso local

Após iniciar o projeto, a aplicação ficará disponível no endereço padrão do Rails:

```txt
http://localhost:3000
```

### Execução com Docker

```bash
docker compose build
docker compose up
```

## Estrutura funcional do projeto

Atualmente o sistema possui funcionalidades como:

- cadastro e autenticação de usuários
- definição de perfil de acessibilidade
- missões por tipo: leitura, foco e desafio
- cálculo de XP por desempenho
- acompanhamento de nível e sequência
- edição de perfil com foto

## Diagrama do modelo lógico do banco de dados

> Inserir imagem do modelo lógico aqui

```md
![Diagrama do modelo lógico](./docs/modelo-logico.png)
```
