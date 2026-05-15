## Project Context

Focus is an inclusive learning PWA for students with dyslexia and ADHD (TDH in Portuguese), built for the 2º Hackathon SIF/UniRios 2026. Theme: "Transforming Education and Learning with Technology and Inclusion."

Two user roles: `aluno` (student) and `professor` (teacher).

## Design Rules (mandatory — read STYLE.md before any UI work)

- Background always `#F5F0E8` — never pure white `#FFFFFF`
- Never use red, not even for errors — use amber `#CA8A04`
- Primary color: `#4A6FA5` (muted slate blue)
- Minimum font size: 16px
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

- Business logic in `app/services/` (e.g. `XpCalculatorService`)
- Controllers stay thin — no business logic, only redirect/render
- Complex queries as scopes on models, not inline in controllers
- Stimulus controllers in `app/javascript/controllers/`

## User model fields (add to authentication migration before db:migrate)

```ruby
t.string  :name,                    null: false
t.string  :role,         default: "aluno"   # aluno | professor
t.string  :perfil_acessibilidade             # dislexia | tdh | ambos
t.integer :xp_total,    default: 0
t.integer :nivel,        default: 1
t.integer :sequencia_dias, default: 0
t.references :turma, foreign_key: true
```

## Notes for future edits

- Prefer `bin/*` wrappers over raw gem executables
- No Redis — use Solid Queue/Cache/Cable already configured
- Always check STYLE.md before any UI work
- One migration per feature — add all fields before running `db:migrate`