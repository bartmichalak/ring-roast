# Prompt: AI-Powered Roasts

Add AI-generated roast text to the workout stats cards using OpenAI.

## Setup

Add the OpenAI client library for this project's language. The API key is available as `OPENAI_API_KEY` environment variable (already in `.env`).

## Roast generator

Create a service that takes the computed workout stats and returns a roast string for each card.

Use `gpt-4o-mini` with temperature 0.9. Send two messages:
- **System**: "You are a savage but funny fitness roast comedian. Roasts are 1-2 sentences max, punchy, brutal but not mean. Respond in valid JSON only with exactly these keys: summary, most_common_type, longest_workout, totals."
- **User**: Include the actual stats (workout count, duration, favorite type, longest session, calories, distance, heart rate) and ask for 4 roasts matching those keys.

Parse the JSON response. When the API fails or returns invalid JSON, log the error and return empty results — never raise. Cards display stats with or without roast text.

## Wire it in

After computing stats in the controller, call the roast generator and pass results to the view. Each card shows the roast as a large quote above the stats.

## Verify

Run tests (inject a fake client — no real API calls in tests), then test the full flow in a browser. Each card should now show a roast quote.
