# Prompt: Integrate with Open Wearables

Integrate this project with [Open Wearables](https://openwearables.io/docs/dev-guides/backend-e2e-integration) — a unified API for connecting wearable devices and accessing health data. API endpoints and response formats are in the CLAUDE.md quick reference.

## What to build

1. **API client service** — reusable client with methods for: create user, list providers, get authorize URL, get connections. Read credentials from ENV vars. Raise custom errors on non-2xx; catch in controllers, show flash messages.

2. **User linking** — on first wearable connect, register user via API, store returned UUID. Skip if already linked.

3. **Provider selection page** — card grid of providers from the API. Use `provider` field in URLs, `name` for display, `icon_url` for images (prepend API base URL).

4. **OAuth flow** — register user if needed → get authorize URL with callback `redirect_uri` → redirect to provider → on callback verify connection → flash message → home.

5. **Connection status** — load connections in the **controller**, show as badges on home page.

## Verify

Run tests. Then restart the app (`docker compose restart web` — needed for Rails to pick up the new `app/services/` directory) and test in browser: connect → OAuth → callback → success flash + badge.
