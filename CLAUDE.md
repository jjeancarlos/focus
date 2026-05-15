# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- Ruby 3.4.8 (`.ruby-version`)
- Rails 8.1.1
- PostgreSQL
- Propshaft for assets
- `tailwindcss-rails` is installed, but there is no frontend build pipeline configured beyond default Rails assets
- Solid Cache, Solid Queue, and Solid Cable are configured via Rails gems instead of Redis-backed adapters
- Kamal + Docker for production deploy

## Common commands

### Setup and local development

```bash
bin/setup
```

`bin/setup --skip-server` installs gems, runs `bin/rails db:prepare`, and clears logs/tmp without starting the server.

```bash
bin/rails server
bin/dev
```

`bin/dev` currently only execs `bin/rails server`; there is no Foreman/Procfile-based local process orchestration in this repo.

### Database

```bash
bin/rails db:prepare
bin/rails db:migrate
bin/rails db:seed
```

Test database prep:

```bash
bin/rails db:test:prepare
```

### Tests

Run all non-system tests:

```bash
bin/rails test
```

Run a single test file:

```bash
bin/rails test test/models/some_model_test.rb
```

Run a single test by line number:

```bash
bin/rails test test/models/some_model_test.rb:42
```

Run system tests:

```bash
bin/rails test:system
```

Run the same sequence used by `bin/ci`:

```bash
bin/ci
```

`bin/ci` runs setup, RuboCop, bundler-audit, Brakeman, Rails tests, system tests, and `db:seed:replant` in test.

### Lint and security

```bash
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit
```

### Production container / deploy

Build the production image:

```bash
docker build -t focus .
```

Kamal deploy configuration lives in `config/deploy.yml`:

```bash
bin/kamal setup
bin/kamal deploy
bin/kamal logs
```

## Architecture

This repository is still very close to a fresh Rails 8 application. There is no domain-specific app code yet beyond framework base classes and default layouts.

### Request / app structure

- `config/routes.rb` only exposes the Rails health endpoint at `/up`
- No application root route is defined
- `app/controllers`, `app/models`, `app/jobs`, and `app/mailers` only contain base application classes
- PWA templates exist under `app/views/pwa`, but the related routes are commented out

When adding product code, expect to establish the first real domain boundaries rather than fitting into an existing feature architecture.

### Data and infrastructure

- Development/test use PostgreSQL databases `focus_development` and `focus_test` from `config/database.yml`
- Production uses separate databases for primary, cache, queue, and cable roles
- Queueing, caching, and Action Cable are intended to use the Solid adapters (`solid_queue`, `solid_cache`, `solid_cable`), not Redis
- `config/deploy.yml` sets `SOLID_QUEUE_IN_PUMA: true`, so job processing is expected to run inside the web process until the app is split across dedicated job servers

### Assets and frontend

- Asset delivery uses Propshaft
- Global stylesheet entrypoint is `app/assets/stylesheets/application.css`
- `tailwindcss-rails` is present in the Gemfile, but there are no custom Tailwind config files or app-specific frontend components yet
- The default HTML layout is `app/views/layouts/application.html.erb`

### Code loading and extension points

- `config/application.rb` enables `config.autoload_lib(ignore: %w[assets tasks])`, so POROs placed in `lib/` are autoloaded
- This is the main existing extension point outside the standard Rails directories

## CI behavior

GitHub Actions in `.github/workflows/ci.yml` run four jobs:

- Brakeman
- bundler-audit
- RuboCop
- test / system-test against PostgreSQL

CI installs `libpq-dev`, starts a PostgreSQL service, and runs tests with `DATABASE_URL=postgres://postgres:postgres@localhost:5432`.

## Notes for future edits

- Prefer `bin/*` wrappers over raw gem executables
- Do not assume Redis, Docker Compose, or Foreman-based multi-process local dev are wired up here; those are not present in this repository today
- If you add UI work, check `STYLE.md` first if that file exists in the repo, because project-level instructions require it for styling decisions
