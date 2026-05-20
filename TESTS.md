# TESTS.md

# Propósito

Este documento define o fluxo oficial de testes, validação, qualidade, segurança, lint, CI/CD e desenvolvimento assistido por IA para o projeto **Focus**.

Ele serve como contrato operacional para:
- desenvolvedores humanos
- Claude Code
- agentes de IA
- pipelines de CI/CD
- validações automatizadas

Os objetivos são:
- deploys mais confiáveis
- pipelines estáveis
- testes determinísticos
- segurança básica contínua
- consistência de engenharia
- mudanças compatíveis com a stack real do projeto

---

# Stack real deste projeto

Este repositório usa hoje:
- **Ruby 3.4.8**
- **Rails 8.1.1**
- **PostgreSQL**
- **Minitest** como framework de testes
- **Capybara + Selenium headless Chrome** para testes de sistema
- **RuboCop Rails Omakase** para lint
- **Brakeman** para análise estática de segurança
- **Bundler Audit** para gems vulneráveis
- **GitHub Actions** para CI

Este projeto **não usa RSpec** como framework principal.
Este projeto também **não depende de npm/yarn como etapa obrigatória de validação atual**.

---

# Princípios de engenharia

## Princípios gerais

- Prefira código explícito e legível.
- Mantenha os testes determinísticos e isolados.
- Corrija regressões cedo.
- Falhe rápido em problemas de validação.
- Use automação sempre que possível.
- Não quebre segurança para “fazer o CI passar”.
- Prefira os wrappers `bin/*` do projeto.
- Mantenha consistência com o que a CI realmente executa.
- Priorize manutenção e clareza acima de abstrações desnecessárias.

---

# Regras para agentes de IA

Estas regras valem para qualquer IA que trabalhe neste repositório.

## Fluxo obrigatório

Antes de considerar qualquer tarefa concluída, sempre:

1. Ler o contexto do projeto (`CLAUDE.md`, `STYLE.md`, arquivos relevantes)
2. Identificar o impacto da mudança
3. Rodar as validações aplicáveis a essa mudança
4. Corrigir falhas encontradas
5. Reexecutar as validações afetadas
6. Reexecutar a validação completa quando a mudança for relevante
7. Resumir o que foi alterado e como foi validado

## O que a IA nunca deve fazer

- Desativar testes para passar CI
- Remover testes sem aprovação
- Ignorar warning de segurança sem justificar
- Pular etapas de validação relevantes
- Silenciar lint globalmente para esconder problema
- Bypassar autenticação ou autorização
- Falsificar cobertura ou execução de teste
- Marcar testes como pendentes sem motivo claro
- Alterar a pipeline para esconder erro local
- Assumir ferramentas inexistentes no projeto

---

# Definição de pronto

Uma tarefa só está pronta quando, conforme aplicável:

- os testes relevantes passam
- `bin/rubocop` passa
- `bin/brakeman` passa
- `bin/bundler-audit` passa
- migrations/preparo de banco continuam funcionando
- a mudança permanece compatível com a CI
- novas features têm testes apropriados quando necessário
- testes existentes continuam estáveis
- documentação foi atualizada se a mudança exigir

---

# Fluxo padrão de validação

Ordem recomendada neste projeto:

1. Instalar dependências Ruby
2. Preparar banco
3. Rodar lint Ruby
4. Rodar scanners de segurança
5. Rodar testes Rails
6. Rodar testes de sistema quando afetados
7. Validar seeds quando a mudança tocar dados/setup
8. Rodar a pipeline completa com `bin/ci` antes de merge importante

---

# Instalação de dependências

## Gems

```bash
bundle install
```

Se for primeiro setup local:

```bash
bin/setup
```

ou

```bash
bin/setup --skip-server
```

---

# Banco de dados

## Preparar banco local

```bash
bin/rails db:prepare
```

## Rodar migrations

```bash
bin/rails db:migrate
```

## Reverter última migration

```bash
bin/rails db:rollback
```

## Preparar banco de teste

```bash
bin/rails db:test:prepare
```

## Replantar seeds no ambiente de teste

```bash
env RAILS_ENV=test bin/rails db:seed:replant
```

## Boas práticas para migration

- Prefira migrations reversíveis
- Evite migrations destrutivas
- Evite locks longos
- Adicione índices com cuidado
- Mantenha migrations pequenas e focadas
- Não misture migração de schema com data migration sem necessidade real

---

# Testes

## Framework oficial

O projeto usa **Minitest**.

As categorias existentes incluem:
- controller tests
- model tests
- service tests
- system tests

## Estrutura atual de testes

Exemplos reais do repositório:
- `test/controllers/`
- `test/models/`
- `test/services/`
- `test/system/`
- `test/fixtures/`
- `test/test_helper.rb`
- `test/application_system_test_case.rb`

## Configuração relevante já existente

- `test/test_helper.rb`
  - roda testes em paralelo
  - carrega `fixtures :all`
  - limpa cache em `setup`
- `test/application_system_test_case.rb`
  - usa Selenium com `headless_chrome`
  - tamanho de tela: `1400x1400`

---

# Execução de testes

## Suite completa de testes Rails

```bash
bin/rails test
```

## Testes de sistema

```bash
bin/rails test:system
```

## Controller/model/service específico

```bash
bin/rails test test/controllers/sessions_controller_test.rb
```

```bash
bin/rails test test/models/user_test.rb
```

```bash
bin/rails test test/services/xp_calculator_service_test.rb
```

## Rodar um teste específico por linha

```bash
bin/rails test test/controllers/sessions_controller_test.rb:18
```

## Pipeline local completa

```bash
bin/ci
```

---

# Categorias recomendadas de teste

## Unitários / modelo

Validam comportamento isolado de models e regras pequenas.

## Controller tests

Validam:
- status HTTP
- redirecionamentos
- flash messages
- autenticação
- autorização
- fluxo por papel (`aluno` / `professor`)

## Service tests

Validam regras de negócio em `app/services`, como cálculo de XP e fluxos de missão.

## System tests

Validam fluxos completos no navegador, por exemplo:
- login
- cadastro em etapas
- navegação principal
- missões
- interações críticas de UI

## Testes de segurança

Sempre considere validar:
- autenticação
- autorização
- limites por papel
- redirecionamentos seguros
- manipulação de entrada do usuário

---

# Fixtures

O projeto usa **fixtures** nativas do Rails, não FactoryBot.

Arquivos atuais incluem, por exemplo:
- `test/fixtures/users.yml`
- `test/fixtures/turmas.yml`
- `test/fixtures/atividades.yml`
- `test/fixtures/recados.yml`

## Regras para fixtures

- mantenha fixtures pequenas e legíveis
- evite criar dependências implícitas difíceis de entender
- não use fixtures para esconder estado complexo demais
- prefira nomes claros para usuários, turmas e relações de teste

---

# Lint e formatação

## RuboCop

O projeto usa o wrapper:

```bash
bin/rubocop
```

## Executar RuboCop

```bash
bin/rubocop
```

## Auto-correção

Se necessário:

```bash
bundle exec rubocop -A
```

## Diretrizes de lint

- prefira guard clauses
- mantenha métodos pequenos
- reduza duplicação
- priorize legibilidade
- use nomes descritivos
- não introduza complexidade desnecessária

---

# Segurança

## Brakeman

Scanner estático de segurança para Rails.

Executar com:

```bash
bin/brakeman --no-pager
```

Na pipeline local completa, o projeto já usa:

```bash
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
```

## O que observar

- autenticação e autorização
- redirects inseguros
- input não confiável
- XSS
- SQL injection
- parâmetros inseguros

---

# Auditoria de gems

## Bundler Audit

Executar com:

```bash
bin/bundler-audit
```

Se precisar usar diretamente:

```bash
bundle audit update
bundle audit
```

---

# Frontend e assets

O projeto usa Tailwind via `tailwindcss-rails` e Propshaft.

Hoje não existe uma etapa obrigatória documentada de ESLint/Prettier na CI.

Portanto:
- não invente `npm run lint` como requisito oficial
- não trate `yarn lint` ou `prettier` como padrão do projeto
- valide frontend por:
  - testes de sistema quando aplicável
  - checagem visual/manual
  - compatibilidade com o design system em `STYLE.md`

---

# Testes de sistema

## Capybara + Selenium

Os testes de sistema atuais usam:
- `capybara`
- `selenium-webdriver`
- Chrome headless

## Casos comuns

- fluxo de login
- fluxo de cadastro
- navegação entre páginas
- formulários
- interações com UI crítica

## Observação importante

Na GitHub Actions, screenshots de falha em system tests são preservadas como artifact em `tmp/screenshots`.

---

# Seeds e consistência de dados

A pipeline local `bin/ci` valida também se as seeds continuam funcionando:

```bash
env RAILS_ENV=test bin/rails db:seed:replant
```

Se sua mudança tocar:
- `db/seeds.rb`
- models usados por seed
- validações obrigatórias
- associações

então essa etapa é obrigatória antes do merge.

---

# Logging e debugging

## Boas práticas

- registre eventos úteis
- nunca logue segredos
- prefira mensagens acionáveis
- mantenha bugs reproduzíveis
- não use logs como substituto de teste

---

# CI/CD

## Pipeline real do projeto

A GitHub Actions atual está em:

- `.github/workflows/ci.yml`

Ela possui estes jobs:

### 1. `scan_ruby`
Executa:
- checkout
- setup do Ruby
- `bin/brakeman --no-pager`
- `bin/bundler-audit`

### 2. `lint`
Executa:
- checkout
- setup do Ruby
- cache do RuboCop
- `bin/rubocop -f github`

### 3. `test`
Executa:
- PostgreSQL em service container
- instalação de `libpq-dev`
- setup do Ruby
- `bin/rails db:test:prepare test`

### 4. `system-test`
Executa:
- PostgreSQL em service container
- instalação de `libpq-dev`
- setup do Ruby
- `bin/rails db:test:prepare test:system`
- upload de screenshots em falha

## Compatibilidade com a CI

Toda mudança deve considerar esse contrato real.

Se algo passa localmente mas quebra em qualquer um desses 4 jobs, a tarefa não está pronta.

---

# Pipeline local oficial

O projeto já define uma pipeline local em:

- `bin/ci`
- `config/ci.rb`

Ela roda, nesta ordem:

1. `bin/setup --skip-server`
2. `bin/rubocop`
3. `bin/bundler-audit`
4. `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
5. `bin/rails test`
6. `bin/rails test:system`
7. `env RAILS_ENV=test bin/rails db:seed:replant`

## Recomendação

Antes de merge importante ou entrega relevante:

```bash
bin/ci
```

---

# Recuperação de falha

Se a CI falhar:

1. leia o log completo
2. identifique a etapa exata que falhou
3. corrija a causa raiz
4. reexecute a validação afetada
5. reexecute a pipeline completa
6. verifique se não introduziu regressões
7. resuma o que foi corrigido

---

# Categorias comuns de falha

## Falha de teste

Geralmente causada por:
- expectativa incorreta
- regra de negócio quebrada
- fixture inconsistente
- vazamento de estado
- autenticação/autorização quebrada

## Falha de lint

Geralmente causada por:
- estilo inconsistente
- complexidade excessiva
- nomenclatura ruim
- padrões inseguros ou pouco legíveis

## Falha de segurança

Geralmente causada por:
- redirects inseguros
- input sem tratamento adequado
- autorização insuficiente
- queries ou uso de params arriscado

## Falha de CI

Geralmente causada por:
- dependência ausente
- divergência entre ambiente local e CI
- banco mal preparado
- seeds quebradas
- system tests frágeis

---

# Hooks locais

Hooks de pre-commit são opcionais, mas recomendados.

## Exemplo de pre-commit

Arquivo:

```bash
.git/hooks/pre-commit
```

Conteúdo sugerido:

```bash
#!/bin/sh

bin/rubocop || exit 1
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error || exit 1
bin/bundler-audit || exit 1
bin/rails test || exit 1
```

Se a mudança afetar UI crítica:

```bash
bin/rails test:system || exit 1
```

---

# Workflow local recomendado

Antes de abrir PR:

```bash
bundle install
bin/rails db:prepare
bin/rubocop
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
bin/bundler-audit
bin/rails test
```

Se a mudança tocar interface, navegação, autenticação, cadastro ou fluxos completos:

```bash
bin/rails test:system
```

Se a mudança tocar seeds, models ou dados base:

```bash
env RAILS_ENV=test bin/rails db:seed:replant
```

Para validação completa:

```bash
bin/ci
```

---

# Workflow recomendado para IA

Fluxo sugerido para agentes assistidos por IA:

1. entender o contexto do projeto
2. localizar arquivos afetados
3. aplicar mudança mínima necessária
4. rodar validações relevantes
5. corrigir falhas
6. rodar pipeline compatível com CI
7. resumir mudanças e validações executadas

---

# Ferramentas compatíveis com este projeto

Ferramentas de apoio possíveis:
- Claude Code
- GitHub Actions
- RuboCop
- Brakeman
- Bundler Audit
- Capybara
- Selenium WebDriver

---

# Recomendações de manutenção

Regularmente:
- atualizar gems com cuidado
- revisar advisories de segurança
- remover testes obsoletos apenas com justificativa
- refatorar duplicação real
- estabilizar testes frágeis
- revisar o tempo da CI
- manter `README.md`, `CLAUDE.md` e este `TESTS.md` coerentes

---

# Objetivo final

A pipeline de validação deste projeto deve:
- detectar regressões cedo
- manter confiança em merge e deploy
- impedir código inseguro
- preservar manutenção do código
- refletir a stack real do Focus
- permitir desenvolvimento assistido por IA com segurança
