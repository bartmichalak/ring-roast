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
# Setup & run
./bin/setup                          # Install deps, create DBs, start server
./bin/dev                            # Start dev server (port 3000)
bin/jobs                             # Start background job processor

# Database
bin/rails db:prepare                 # Create or migrate
bin/rails db:migrate                 # Run pending migrations

# Testing
bin/rails test                       # Run all tests (parallel by default)
bin/rails test test/models/foo_test.rb          # Single test file
bin/rails test test/models/foo_test.rb:42       # Single test by line number
bin/rails test:system                # System tests (Capybara + headless Chrome)

# Code quality
bin/rubocop                          # Lint (rubocop-rails-omakase style)
bin/rubocop -a                       # Auto-fix safe issues
bin/brakeman                         # Security scan
```

## Code Conventions

- **Service objects for business logic**: Controllers should only handle calling services and rendering responses. All business logic belongs in service objects (`app/services/`).
- **Services must have tests**: Every service must be covered by tests (`test/services/`).

## Architecture Notes

- **Multiple SQLite databases in production**: Primary, cache (Solid Cache), queue (Solid Queue), and cable (Solid Cable) each have their own `.sqlite3` file in `storage/`.
- **JS via ImportMap**: All JavaScript imports are configured in `config/importmap.rb`. No npm/yarn. Stimulus controllers auto-load from `app/javascript/controllers/`.
- **Browser restriction**: `ApplicationController` enforces `allow_browser versions: :modern` (requires CSS nesting, import maps, etc.).
- **Tailwind CSS**: Styling uses Tailwind via `tailwindcss-rails`. Run `bin/dev` (not `rails s`) to start the Tailwind watcher alongside the server.
- **Rails credentials for secrets**: Use `Rails.application.credentials` instead of ENV variables for API keys and configuration. To edit credentials programmatically, create a script that writes to `$1` and pass it as `EDITOR`:
  ```bash
  # 1. Write a script that overwrites the temp file:
  cat > /tmp/edit_creds.sh << 'SCRIPT'
  #!/bin/bash
  cat > "$1" << 'EOF'
  secret_key_base: <existing_key>

  open_wearables:
    api_key: <your_key>
    api_url: <your_url>
  EOF
  SCRIPT
  chmod +x /tmp/edit_creds.sh

  # 2. Run credentials:edit with the script as EDITOR:
  EDITOR="/tmp/edit_creds.sh" bin/rails credentials:edit
  ```
- **Kamal deploy config** (`config/deploy.yml`) is a template - needs server IPs and registry credentials before use.
