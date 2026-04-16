# Prompt: Workout Roast

Pull workout data from Open Wearables and display it as a Spotify Wrapped-style fullscreen card presentation.

## Workout data

Add a method to fetch workouts from the Open Wearables API. The endpoint, response format, field names, and pagination pattern are documented in the "Retrieve Health Data" section:
https://openwearables.io/docs/dev-guides/backend-e2e-integration

Fetch the last 30 days of workouts. Handle cursor-based pagination to get all results.

## Stats cards

Compute 4 stats from the raw workout data:
- **Summary** — total workout count and total training time
- **Most common type** — favorite workout type with count and percentage
- **Longest session** — longest workout with name, duration, date
- **Totals** — total calories, distance (km), average heart rate

Handle missing/null fields gracefully — not all workouts have every metric.

## Fullscreen presentation

Build a fullscreen page with bold, vibrant random background colors (Spotify Wrapped style). White text, large typography. Navigate with arrow keys, touch swipe, and Escape to close. Progress dots at top, close button.

No workouts → "No Workouts Yet" card. No wearable connected → redirect to connections page.

Add a "See My Roast" button on the home page, visible only when a wearable is connected.

## Verify

Run tests, then test the full flow in a browser.
