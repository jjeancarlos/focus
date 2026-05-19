## Project Context

Focus is an inclusive learning PWA for students with dyslexia and ADHD (TDH in Portuguese), built for the 2º Hackathon SIF/UniRios 2026. Theme: "Transforming Education and Learning with Technology and Inclusion."

Two user roles: `aluno` (student) and `professor` (teacher).

## Design Rules (mandatory — read STYLE.md before any UI work)

- Background always `#FAFAF7` — never pure white `#FFFFFF`
- Card background `#F5F5EF`
- Never use red, not even for errors — use amber `#CA8A04`
- Primary color: `#3B6FE8`
- Primary dark color: `#1E40AF`
- Minimum font size: 16px in UI; avoid anything below that for interactive and learning content
- Buttons minimum 48px height (touch targets)
- Font: OpenDyslexic for dyslexia/both profiles, Arial fallback
- Feedback always positive: "Quase lá! Tente de novo." — never "Errado."
- Icons always accompanied by text labels
- Check STYLE.md for the full token reference before writing any HTML/CSS

## Domain language

- Atividade = Mission (called "Missão" in UI)
- Mission types: `leitura` (Guided Reading), `foco` (Focus Mission), `desafio` (Challenge)
- Perfil de acessibilidade: `dislexia`, `tdh`, `ambos`
- XP = experience points earned per completed mission
- Sequência = daily streak counter

## Architecture conventions

- Business logic in `app/services/` (e.g. `XpCalculatorService`, `Missoes::FinalizarTentativaService`)
- Controllers stay thin — no business logic, only redirect/render
- Complex queries as scopes on models, not inline in controllers
- App JavaScript currently lives in `app/assets/javascripts/`
- PWA files live in `app/views/pwa/`

## User model fields (implemented in the current schema)

```ruby
t.string  :email_address,          null: false
 t.string  :name,                    null: false, default: ""
 t.string  :password_digest,        null: false
 t.string  :role,                   null: false, default: "aluno"   # aluno | professor
 t.string  :perfil_acessibilidade                                # dislexia | tdh | ambos
 t.integer :xp_total,               null: false, default: 0
 t.integer :nivel,                  null: false, default: 1
 t.integer :sequencia_dias,         null: false, default: 0
 t.references :turma, foreign_key: true
```

## Notes for future edits

- Prefer `bin/*` wrappers over raw gem executables
- No Redis — use Solid Queue/Cache/Cable already configured
- Always check STYLE.md before any UI work
- One migration per feature — add all fields before running `db:migrate`
- If touching PWA metadata, keep `manifest.json.erb` aligned with STYLE.md tokens

## Current stack

- Rails `8.1.1`
- PostgreSQL
- Puma
- Tailwind via `tailwindcss-rails`
- Propshaft
- Turbo
- Active Storage
- Chartkick + Groupdate for dashboards and weekly charts
- Solid Queue / Solid Cache / Solid Cable
- Docker + Kamal deploy
- CI with RuboCop, Brakeman, Bundler Audit and Rails tests

## Current data model

- `User`
  - authentication with `has_secure_password`
  - roles: `aluno`, `professor`
  - optional `belongs_to :turma`
  - `has_many :sessions`
  - `has_many :tentativas, foreign_key: :aluno_id`
  - `has_many :recados_individuais, foreign_key: :aluno_id`
  - `has_many :turmas_como_professor, foreign_key: :professor_id`
  - `has_one_attached :foto`
- `Turma`
  - belongs to `professor`
  - has many `alunos`
  - generates `invite_token`
- `Atividade`
  - types: `leitura`, `foco`, `desafio`
  - stores `descricao`, `conteudo`, `imagem_url`, `perguntas`, `xp_base`, `ativo`
- `Tentativa`
  - belongs to `aluno`
  - optional `belongs_to :atividade`
  - stores `pontuacao`, `tempo_gasto`, `xp_ganho`, `concluida_em`, `tipo_missao`
- `Recado`
  - belongs to `professor`
  - optional target: `turma` or `aluno`
  - `lido` boolean for notification state
- `Session`
  - stores authenticated user sessions

## Current authentication and onboarding flow

- Authentication uses `Current.session` / `Current.user` with signed session cookie
- Login is handled by `SessionsController`
- Password reset flow exists via `PasswordsController` and `PasswordsMailer`
- Student registration is multi-step:
  1. account creation
  2. accessibility profile selection
  3. join turma by invite code or skip
- New self-registered users are created as `aluno`
- Professor access is role-gated and redirects to `professor_dashboard_path`
- Login flow has rate limiting
- Minimum password length is 8

## Current product features implemented

### Aluno

- Student dashboard at `aluno/dashboard`
- Mission hub at `missoes`
- Three mission flows implemented:
  - `leitura` with reading comprehension questions
  - `foco` with timed visual memory questions
  - `desafio` with word ordering challenge
- Mission answering, correction and result screen
- Daily mission limit of 10
- XP gain calculation by accuracy, time and accessibility profile
- Level recalculation based on accumulated XP
- Daily streak tracking
- Conquistas page with achievement milestones
- Perfil page with profile update, foto upload and turma change by code
- Notificações page with recados and daily reminder count

### Professor

- Professor dashboard at `professor/dashboard`
- Create and view turmas
- Invite students through turma `invite_token`
- View turma roster
- View student detail screen with weekly stats
- Send recados to an entire turma or to an individual aluno

## Current routes and areas

- Public:
  - root landing page
  - login via `resource :session`
  - password reset via `resources :passwords, param: :token`
- Cadastro:
  - `cadastro`
  - `cadastro/perfil`
  - `cadastro/turma`
  - `cadastro/pular`
- Aluno:
  - `aluno/dashboard`
  - `missoes`, `missoes/:tipo`, `missoes/:tipo/responder`, `missoes/:tipo/resultado/:tentativa_id`
  - `conquistas`
  - `perfil`, `perfil/turma`
  - `notificacoes`, `notificacoes/contagem`
- Professor:
  - `professor/dashboard`
  - `professor/turmas`
  - `professor/turmas/:turma_id/alunos/:id`
  - `professor/recados`

## Current services and rules already implemented

- `XpCalculatorService`
  - applies XP multipliers for acertos, tempo and perfil de acessibilidade
  - profile multipliers currently exist for `dislexia`, `tdh`, `ambos`
  - guarantees minimum XP gain of 5
- `Missoes::FinalizarTentativaService`
  - persists `Tentativa`
  - updates `xp_total`
  - recalculates `nivel`
  - updates `sequencia_dias`
- `Atividade.sorteada_para(tipo)` is the random mission picker for active content
- `User#limite_diario_atingido?` enforces the student daily cap

## Current seeded demo data

`db/seeds.rb` currently creates:

- professor demo: `professor@focus.com` / `focus123`
- turma demo: `Turma Focus`
- turma invite code: `FOCUS2026`
- aluno demo: `aluno@focus.com` / `focus123`
- sample atividades for all three mission types

## PWA and frontend implementation notes

- App has PWA manifest in `app/views/pwa/manifest.json.erb`
- App has service worker in `app/views/pwa/service-worker.js`
- Frontend styling is Tailwind-based, with entrypoint in `app/assets/tailwind/application.css`
- Local UI JavaScript currently lives in `app/assets/javascripts/ui.js`
- Some runtime UI colors still use older hex values in parts of the app; STYLE.md remains the source of truth when editing UI
- The current PWA manifest still uses red `theme_color` / `background_color` and should be corrected if that file is touched

## Testing and delivery status

- Model, controller, service and system tests already exist
- Authentication flow has system tests
- Mission flow has system tests
- Registration flow has system tests
- CI is configured in `.github/workflows/ci.yml`
- Deploy configuration exists in `config/deploy.yml`
- Development process files exist for Docker and `bin/dev`
