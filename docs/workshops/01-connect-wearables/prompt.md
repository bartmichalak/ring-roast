# Workshop Prompt: Connect Wearables Feature

Integrate this project with [Open Wearables](https://openwearables.io/docs/dev-guides/backend-e2e-integration) — a unified API for connecting wearable devices and accessing health data. Then build the "Connect Your Wearable" feature for Ring Roast.

### API client service

Create a reusable client with methods for: create user, list providers, get authorize URL, get connections. Read credentials from ENV vars. Authenticate via `X-Open-Wearables-API-Key` header (NOT Bearer). Raise custom errors on non-2xx; catch in controllers, show flash messages.

### Anonymous users

The app doesn't require login. A `User` model already exists (`app/models/user.rb`) with auto-generated Kahoot-style funny names (e.g. "FunkyPanda47", "ChaoticSloth12"), and a `CurrentUser` concern creates users on first visit and tracks them via session cookie.

Add an `ow_user_id` field to the `users` table (nullable) — this links a local user to their Open Wearables account. Users don't have an email address.

### Landing page updates

The existing landing page has a disabled "Connect Your Wearable" placeholder button. Update it to:

- Show a welcome greeting with the user's generated name above the hero (e.g. "Welcome, FunkyPanda47")
- Make the connect button an active link to `/connections`
- When the user has connected providers, show them as green badges below the button. Load connections in the **controller** and pass to the view.

Add flash message rendering (success and error) to `application.html.erb` layout — not individual views — so flashes work on every page.

### Provider selection page

Create a page at `/connections` showing available wearable providers in a card grid. Fetch the list from the API, filtering out non-cloud providers (SDK-only integrations like Apple Health, Samsung Health, Google Health Connect). Use `provider` field in URLs, `name` for display, `icon_url` for images (prepend API base URL). Each card links to start the OAuth flow.

### OAuth connect flow

When a user clicks a provider:

1. Create an Open Wearables user if they don't have one yet (`POST /api/v1/users`). Pass the local user's generated name (e.g. "FunkyPanda47") as `first_name` so they're identifiable in the Open Wearables dashboard - we don't have emails or split first/last names.
2. Get the OAuth authorization URL (`GET /api/v1/oauth/{provider}/authorize` with `user_id` and `redirect_uri`)
3. Redirect the user to the provider's OAuth page
4. Handle the callback — verify the connection was established and redirect home with a success/error flash

**Heads up — Turbo + cross-origin redirect:** the provider trigger must be a plain browser navigation, not a Turbo-intercepted fetch. If you use `button_to` (or any Turbo-enabled form) to POST to your backend and then `redirect_to authorization_url, allow_other_host: true`, Turbo follows the 302 inside `fetch()`. The cross-origin hop to the provider becomes a CORS request, the browser sends an `OPTIONS` preflight to e.g. `cloud.ouraring.com`, and the provider rejects it. Disable Turbo on that form (e.g. `form: { data: { turbo: false } }` on `button_to`) so the browser does a native navigation and follows the 302 normally.