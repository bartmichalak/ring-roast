# Workshop Prompt: Workout Roast Feature

## Prompt

Build a Spotify Wrapped-style fullscreen card presentation showing workout stats from the last 30 days.

### Fetching workout data

Add a `get_workouts` method to the existing `OpenWearablesClient` service. It should call `GET /api/v1/users/{user_id}/events/workouts` with `start_date` and `end_date` params. The API returns paginated results (max 100 per page) - handle cursor-based pagination to fetch all workouts in the period.

### Workout stats

Create a `WorkoutStatsService` that takes raw workout data and computes stats for 4 cards:

- **Summary** - total workout count and total training time (formatted like "12h 34m")
- **Most common type** - the workout type they do most, with count and percentage
- **Longest session** - their single longest workout with name, duration, date, and details
- **Totals** - total calories burned, total distance in km, average heart rate

The time period (30 days) should be a configurable constant. Handle missing data gracefully - some workouts may not have calories or distance.

### Fullscreen card presentation

Create a new page at `/roast` with a dedicated fullscreen layout (no margins, no scrolling). Each card takes up the full screen with a bold, vibrant random background color (think Spotify Wrapped - bright pinks, blues, greens, oranges). White text, large typography.

Users navigate between cards using:
- Arrow keys (left/right)
- Touch swipe on mobile
- Escape key to close and return home

Add progress dots at the top showing which card you're on, and a close (X) button.

If the user has no workout data, show a single "No Workouts Yet" card.

If the user hasn't connected a wearable yet, redirect them to `/connections`.

### Landing page

Add a "See My Roast" button on the home page, visible only when the user has connected a wearable.

### Tests

Write tests for the stats service (core business logic), the color service, and the roasts controller. Follow the existing test patterns in the project.

### Verify

Run `bin/rails test`, then start `bin/dev` and go through the full flow: home page -> "See My Roast" -> navigate through cards with arrow keys.
