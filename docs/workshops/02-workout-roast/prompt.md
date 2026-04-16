# Prompt: Workout Roast

Pull workout data from Open Wearables and display as Spotify Wrapped-style fullscreen cards. Workout endpoint and field names are in CLAUDE.md quick reference.

## Workout data

Add a `get_workouts` method to the API client. Fetch last 30 days. Paginate: when `has_more` is true, pass `next_cursor` as `cursor` param. Cap at 10 pages.

## Stats cards

Compute 4 cards:
- **Summary** — count + total training time (e.g. "12h 34m")
- **Most common type** — top `type` with count and percentage
- **Longest session** — by `duration_seconds`, show name/type, duration, date
- **Totals** — sum `calories_kcal`, `distance_meters` → km, avg `avg_heart_rate_bpm`

Nullable fields — skip nulls, don't count as zero.

## Fullscreen presentation

Page at `/roast`, fullscreen layout (`overflow-hidden`). Each card = full screen, vibrant random background (#FF6B35, #FF2D87, #7B2FF7, #00C9A7 etc), white text, large type. Navigate: arrow keys, swipe, Escape. Progress dots + close button.

No workouts → "No Workouts Yet". No wearable → redirect `/connections`. Add "See My Roast" button on home (visible when connected).

## Verify

Run tests, then browser: home → See My Roast → arrow keys through cards → Escape.
