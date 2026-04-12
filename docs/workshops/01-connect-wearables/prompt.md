# Workshop Prompt: Connect Wearables Feature

## Prompt

Build the "Connect Your Wearable" feature for Ring Roast.

### Anonymous users

The app doesn't require login. Instead, create a User model with auto-generated Kahoot-style funny names (e.g. "FunkyPanda47", "ChaoticSloth12") - combine a random adjective + animal + number. Use a big enough word list (~40 each) for variety.

Users should be created automatically on first visit and tracked via session cookie. Store an `ow_user_id` field on the user too (nullable) - this links them to their Open Wearables account later.

### Landing page updates

The existing landing page has a disabled "Connect Your Wearable" placeholder button. Update it to:

- Show a welcome greeting with the user's generated name (e.g. "Welcome, FunkyPanda47")
- Make the connect button actually work - it should link to the provider selection page
- If the user already connected a wearable, show which providers they're connected to

Also add flash message support (success/error) to the application layout.

### Provider selection page

Create a new page at `/connections` that shows available wearable providers in a card grid. Fetch the provider list from the Open Wearables API (`GET /api/v1/oauth/providers?enabled_only=true&cloud_only=true`). Each card should show the provider's icon and name, and link to start the OAuth flow.

### OAuth connect flow

When a user clicks a provider:

1. Create an Open Wearables user if they don't have one yet (`POST /api/v1/users` with `external_user_id`)
2. Get the OAuth authorization URL (`GET /api/v1/oauth/{provider}/authorize` with `user_id` and `redirect_uri`)
3. Redirect the user to the provider's OAuth page
4. Handle the callback - verify the connection was established and redirect home with a success/error flash

### Open Wearables API client

Build a service object for the Open Wearables API. It should read `api_key` and `api_url` from Rails credentials (`Rails.application.credentials.open_wearables`). Use Net::HTTP (no extra gems). Handle errors gracefully - API failures should show user-friendly flash messages, not crash the app.

### Tests

Write tests for the User model, the API client service, and the connections controller. The project uses plain Minitest (no Mocha gem available).

### Credentials

The Open Wearables credentials should be set up in Rails credentials:

```yaml
open_wearables:
  api_key: <your_key>
  api_url: <your_url>
```

### Verify

Run `bin/rails test` to make sure everything passes, then start the app with `bin/dev` and test the full flow in the browser.

---

## Suggested CLAUDE.md additions

Add these to the Architecture Notes / Code Conventions sections to help Claude Code avoid common pitfalls:

```markdown
- **Testing without Mocha**: This project uses plain Minitest without Mocha. Use `define_singleton_method` for stubbing in tests. Do not use `any_instance.stubs` or `require "minitest/mock"` (not available).
- **Open Wearables API**: The API client (`app/services/open_wearables_client.rb`) reads credentials from `Rails.application.credentials.open_wearables` (keys: `api_key`, `api_url`). Provider `icon_url` values are relative paths - prepend `api_url` when rendering.
```
