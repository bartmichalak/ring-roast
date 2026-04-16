# Prompt: Integrate with Open Wearables

Integrate this project with [Open Wearables](https://openwearables.io) — a unified API for connecting wearable devices (Garmin, Whoop, Oura, Polar, Suunto, Strava) and accessing health data through a single REST API.

## Documentation

Read the integration guide first — it has the complete flow, endpoint URLs, response formats, and code examples:
https://openwearables.io/docs/dev-guides/backend-e2e-integration

API reference (endpoint table): https://openwearables.io/docs/api-reference/introduction

## What to build

### 1. API client service

Create a reusable API client with these methods:
- `create_user(external_user_id:)` — `POST /api/v1/users`, returns user object with `id` (UUID)
- `get_providers(...)` — `GET /api/v1/oauth/providers`, returns array of provider objects
- `authorize_provider(provider:, user_id:, redirect_uri:)` — `GET /api/v1/oauth/{provider}/authorize`, returns `authorization_url`
- `get_connections(user_id:)` — `GET /api/v1/users/{user_id}/connections`, returns array of connections

Read `OPEN_WEARABLES_API_URL` and `OPEN_WEARABLES_API_KEY` from environment variables (already in `.env`). Authenticate every request with the `X-Open-Wearables-API-Key` header (NOT Bearer token).

When a call returns non-2xx, raise a custom error with status and body. Catch these errors in controllers — show flash messages, log the error, never crash.

### 2. User linking

When a user first connects a wearable, register them via `POST /api/v1/users` using a unique app identifier as `external_user_id`. Store the returned `id` (UUID) on the user record. Skip if already linked.

### 3. Provider selection page

Create a page listing available providers fetched from `GET /api/v1/oauth/providers?enabled_only=true&cloud_only=true`.

Each provider object has: `provider` (identifier for API calls, e.g. `"garmin"`), `name` (display label, e.g. `"Garmin"`), `icon_url` (relative path — prepend `OPEN_WEARABLES_API_URL` to render). Use `provider` in OAuth URLs, `name` for display.

### 4. OAuth connect flow

When a user clicks a provider:
1. Register the user with OW if not yet linked
2. Get the authorization URL from `GET /api/v1/oauth/{provider}/authorize` with the OW user ID and a callback URL as `redirect_uri`
3. Redirect to the returned `authorization_url`
4. On callback: verify connection via `GET /api/v1/users/{user_id}/connections`, redirect home with success/error flash

### 5. Connection status on home page

Load the user's connections in the **controller** (not in the view) and pass them to the view. Display connected providers as badges.

## Verify

Run tests, then test in browser: connect button → provider selection → OAuth → callback → success flash + provider badge on home page.
