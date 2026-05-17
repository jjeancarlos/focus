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

- Tailwind CSS v4 via `tailwindcss-rails`
- Chartkick
- Chart.js
- Propshaft
- Turbo

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
- Foreman
- Docker

### Configuração inicial

```bash
bundle install
cp .env.example .env
```

Preencha o arquivo `.env` com as variáveis necessárias.

### Banco de dados

```bash
bin/rails db:prepare
```

### Seeds de demonstração

Para carregar os dados iniciais de demonstração:

```bash
bin/rails db:seed
```

As seeds criam:

- professor demo
- turma padrão com código de convite
- aluno demo vinculado à turma
- atividades de leitura, foco e desafio

Credenciais geradas pelas seeds:

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

### Executar em desenvolvimento

```bash
bin/dev
```

Ou com Foreman:

```bash
foreman start -f Procfile.dev
```

### Acesso local

Após iniciar o projeto, a aplicação ficará disponível em:

```txt
http://localhost:3000
```

### Execução com Docker

```bash
docker build -t focus .
docker run --env-file .env -p 3000:3000 focus
```

## Estrutura funcional do projeto

Atualmente o sistema possui funcionalidades como:

- cadastro e autenticação de usuários
- definição de perfil de acessibilidade
- missões por tipo: leitura, foco e desafio
- cálculo de XP por desempenho
- acompanhamento de nível e sequência
- tela de conquistas
- histórico do aluno com gráficos semanais
- edição de perfil com foto
- gestão de turmas para professores
- envio de recados para alunos
- PWA com manifesto e service worker

## Tipos de usuário

- `aluno`
- `professor`

## Modelo lógico do banco de dados

![Diagrama do modelo lógico](./.docs/modelo-logico-banco.png)
