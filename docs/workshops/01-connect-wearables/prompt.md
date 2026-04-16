# Workshop Prompt: Connect Wearables Feature

Build the "Connect Your Wearable" feature for Ring Roast, using the Open Wearables integration from the previous step.

### Anonymous users

The app doesn't require login. Instead, create a User model with auto-generated Kahoot-style funny names (e.g. "FunkyPanda47", "ChaoticSloth12") — combine a random adjective + animal + number. Use a big enough word list (~40 each) for variety.

Users should be created automatically on first visit and tracked via session cookie. Store an `ow_user_id` field on the user (nullable) — this links them to their Open Wearables account.

### Landing page updates

The existing landing page has a disabled "Connect Your Wearable" placeholder button. Update it to:

- Show a welcome greeting with the user's generated name above the hero (e.g. "Welcome, FunkyPanda47")
- Make the connect button an active link to `/connections`
- When the user has connected providers, show them as green badges below the button. Load connections in the **controller** and pass to the view.

Add flash message rendering (success and error) to `application.html.erb` layout — not individual views — so flashes work on every page.

### Provider selection page

Create a page at `/connections` showing available wearable providers in a card grid. Fetch the list from the Open Wearables API. Each card shows the provider's icon and name, and links to start the OAuth flow for that provider.

### OAuth connect flow

When a user clicks a provider:

1. Create an Open Wearables user if they don't have one yet (`POST /api/v1/users` with `external_user_id`)
2. Get the OAuth authorization URL (`GET /api/v1/oauth/{provider}/authorize` with `user_id` and `redirect_uri`)
3. Redirect the user to the provider's OAuth page
4. Handle the callback — verify the connection was established and redirect home with a success/error flash

### Tests

Write tests for the User model, the API client service, and the connections controller.

### Verify

Run tests, then test the full flow in the browser: landing page with greeting → connect wearable → OAuth → redirect back with success flash → connected provider badge on home page.
