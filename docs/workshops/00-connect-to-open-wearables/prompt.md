# Prompt: Integrate with Open Wearables

Integrate this project with [Open Wearables](https://openwearables.io) — a unified API for connecting wearable devices (Garmin, Whoop, Oura, Polar, Suunto, Strava) and accessing health data through a single REST API.

## Documentation

Read these before implementing:
- **Integration guide** (full flow, code examples, response formats): https://openwearables.io/docs/dev-guides/backend-e2e-integration
- **API reference** (all endpoints): https://openwearables.io/docs/api-reference/introduction

## What to build

### 1. API client

Create a reusable service for the Open Wearables REST API. Environment variables `OPEN_WEARABLES_API_URL` and `OPEN_WEARABLES_API_KEY` are already configured in `.env`.

All requests authenticate via the `X-Open-Wearables-API-Key` header (NOT Bearer token). See the integration guide for details and code examples.

### 2. User linking

When a user connects their first wearable, register them in Open Wearables via `POST /api/v1/users` and store the returned UUID. Use a unique identifier from your app as `external_user_id`.

### 3. Provider selection

Build a page where users choose which wearable to connect. Fetch available providers from `GET /api/v1/oauth/providers?enabled_only=true&cloud_only=true`.

### 4. OAuth connect flow

Follow the integration guide's OAuth flow:
1. Get the authorization URL from `GET /api/v1/oauth/{provider}/authorize` with `user_id` and `redirect_uri`
2. Redirect the user to the `authorization_url` from the response
3. Handle the callback — verify the connection via `GET /api/v1/users/{user_id}/connections`
4. Show success/error feedback

### 5. Connection status

Show which providers the user has connected (e.g. on the home page).

### 6. Error handling

All API errors should result in user-friendly messages, never unhandled exceptions.

## Verify

Run tests, then test the full OAuth connect flow in a browser.
