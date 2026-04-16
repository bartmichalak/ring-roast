# Prompt: Workout Roast

Pull workout data from Open Wearables and display it as a Spotify Wrapped-style fullscreen card presentation.

## Workout data

Add a method to fetch workouts from the Open Wearables API. The endpoint, response format, and field names are in the "Retrieve Health Data" section:
https://openwearables.io/docs/dev-guides/backend-e2e-integration

Fetch the last 30 days of workouts. The API uses cursor-based pagination — when `pagination.has_more` is true, pass `pagination.next_cursor` as the `cursor` param in the next request. Cap at 10 pages.

## Stats cards

Compute 4 cards from the raw workout data:
- **Summary** — total workout count and total training time (e.g. "12h 34m")
- **Most common type** — the workout `type` they do most, with count and percentage
- **Longest session** — longest workout by `duration_seconds`, with name, formatted duration, and date
- **Totals** — total `calories_kcal`, total `distance_meters` converted to km, average `avg_heart_rate_bpm`

These fields may be null for some workouts — skip null values when computing totals (don't count them as zero).

## Fullscreen presentation

Create a page at `/roast` with a dedicated fullscreen layout (no margins, no scrolling, `overflow-hidden`). Each card fills the entire screen with a bold, vibrant random background color (#FF6B35, #FF2D87, #7B2FF7, #00C9A7 etc). White text, large typography.

Navigation: arrow keys (left/right), touch swipe on mobile, Escape to close. Progress dots at top, close (X) button.

When there are no workouts, show a single "No Workouts Yet" card. When no wearable is connected, redirect to `/connections`.

Add a "See My Roast" button on the home page, visible only when the user has connected a wearable.

## Verify

Run tests, then test the full flow in a browser: home → "See My Roast" → navigate cards with arrow keys → Escape to close.
