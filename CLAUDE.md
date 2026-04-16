# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ring Roast is a Rails 8.0.5 web application (Ruby 3.3.1, SQLite3) that demonstrates how to integrate with the [Open Wearables](https://openwearables.io/docs) platform - a unified API for connecting and syncing health data from multiple wearable devices.

### Purpose

This app is a reference implementation showing three core integration patterns:

1. **User auth flow with wearable providers** - Generate connection links via the Open Wearables API, redirect users to authenticate with their wearable provider (Garmin, Whoop, Oura, Polar, Suunto, Strava, etc.), and handle the OAuth callback.
2. **Pulling data from the Open Wearables API** - Fetch normalized health data (heart rate, sleep, activity, steps, HRV, recovery, strain) through the unified REST API.
3. **Receiving webhooks from Open Wearables** - Accept incoming webhook notifications when new health data or health insight automations are triggered.

### Open Wearables Concepts

- **Unified API**: Single REST API (authenticated via `X-Open-Wearables-API-Key` header) that normalizes data across all wearable providers.
- **Providers**: Wearable platforms the user connects - cloud-based (Garmin, Whoop, Polar, Suunto, Strava, Oura) and SDK-based (Apple HealthKit, Samsung Health, Google Health Connect).
- **Connect flow**: Generate a connection link for a user -> user authenticates with their provider via OAuth -> data syncs automatically -> access via API.
- **Health data types**: Activity/workouts, sleep (stages, efficiency, duration), biometrics (heart rate, HRV), recovery scores, strain metrics, steps.
- **Docs**: https://openwearables.io/docs | **API Reference**: https://openwearables.io/docs/api-reference/introduction | **Backend E2E Guide**: https://openwearables.io/docs/dev-guides/backend-e2e-integration

## Key Stack Choices

- **Frontend**: Hotwire (Turbo + Stimulus) with ImportMap (no Node.js/bundler needed)
- **CSS**: Tailwind CSS via `tailwindcss-rails`
- **Asset pipeline**: Propshaft
- **Background jobs**: Solid Queue (database-backed)
- **Caching**: Solid Cache (database-backed)
- **WebSockets**: Solid Cable (database-backed)
- **Deployment**: Docker + Kamal
- **Web server**: Puma with Thruster (HTTP caching/compression)

## Common Commands

```bash
# Setup & run (Docker - no Ruby needed, recommended for workshop)
cp .env.example .env                 # Then fill in your API keys
docker compose up                    # Build & start dev server (port 3100)

# Running commands inside Docker container
docker compose exec web bin/rails test                              # Run all tests
docker compose exec web bin/rails test test/models/foo_test.rb      # Single test file
docker compose exec web bin/rails test test/models/foo_test.rb:42   # Single test by line
docker compose exec web bin/rails db:migrate                        # Run pending migrations
docker compose exec web bundle install                              # Install new gems

# Setup & run (local Ruby - alternative if Ruby 3.3.1 is installed)
./bin/setup                          # Install deps, create DBs, start server
./bin/dev                            # Start dev server (port 3000)
bin/jobs                             # Start background job processor

# Code quality
bin/rubocop                          # Lint (rubocop-rails-omakase style)
bin/rubocop -a                       # Auto-fix safe issues
bin/brakeman                         # Security scan
```

## Code Conventions

- **Service objects for business logic**: Controllers should only handle calling services and rendering responses. All business logic belongs in service objects (`app/services/`).
- **Services must have tests**: Every service must be covered by tests (`test/services/`).
- **Testing without Mocha**: This project uses plain Minitest without Mocha. Use `define_singleton_method` for stubbing in tests. Do not use `any_instance.stubs` or `require "minitest/mock"` (not available).
- **Open Wearables API**: See the quick reference below. Full docs: https://openwearables.io/docs/dev-guides/backend-e2e-integration

## Open Wearables API Quick Reference

Auth: `X-Open-Wearables-API-Key` header (NOT Bearer). Credentials: `ENV["OPEN_WEARABLES_API_URL"]`, `ENV["OPEN_WEARABLES_API_KEY"]`.

| Method | Endpoint | Body/Params | Response |
|--------|----------|-------------|----------|
| POST | `/api/v1/users` | `{external_user_id: "..."}` | `{id: "uuid", external_user_id: "..."}` |
| GET | `/api/v1/oauth/providers?enabled_only=true&cloud_only=true` | — | `[{provider: "garmin", name: "Garmin", icon_url: "/static/..."}]` |
| GET | `/api/v1/oauth/{provider}/authorize?user_id=...&redirect_uri=...` | — | `{authorization_url: "https://..."}` |
| GET | `/api/v1/users/{user_id}/connections` | — | `[{provider: "garmin", status: "active"}]` |
| GET | `/api/v1/users/{user_id}/events/workouts?start_date=...&end_date=...&limit=100` | — | `{data: [...], pagination: {next_cursor, has_more}}` |

**Workout fields**: `type`, `name` (nullable), `start_time`, `duration_seconds`, `calories_kcal` (nullable), `distance_meters` (nullable), `avg_heart_rate_bpm` (nullable).

**Provider `icon_url`** is a relative path — prepend `OPEN_WEARABLES_API_URL` to render.

## Architecture Notes

- **Multiple SQLite databases in production**: Primary, cache (Solid Cache), queue (Solid Queue), and cable (Solid Cable) each have their own `.sqlite3` file in `storage/`.
- **JS via ImportMap**: All JavaScript imports are configured in `config/importmap.rb`. No npm/yarn. Stimulus controllers auto-load from `app/javascript/controllers/`.
- **Browser restriction**: `ApplicationController` enforces `allow_browser versions: :modern` (requires CSS nesting, import maps, etc.).
- **Tailwind CSS**: Styling uses Tailwind via `tailwindcss-rails`. The Tailwind watcher runs automatically with `docker compose up` or `bin/dev`.
- **Docker dev environment**: Docker Compose maps port **3100** on host to 3000 in container. Access the app at `http://localhost:3100`. Source code is volume-mounted so file changes are reflected immediately.
- **Secrets via ENV variables**: API keys are configured through environment variables (`OPEN_WEARABLES_API_KEY`, `OPEN_WEARABLES_API_URL`, `OPENAI_API_KEY`). Copy `.env.example` to `.env` and fill in your values. Docker Compose loads `.env` automatically.
- **Kamal deploy config** (`config/deploy.yml`) is a template - needs server IPs and registry credentials before use.
