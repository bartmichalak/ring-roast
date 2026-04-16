# Prompt: AI-Powered Roasts

Add AI-generated roast text to the workout stats cards using OpenAI.

## Setup

Add the OpenAI client library for this project's language. The API key is available as `OPENAI_API_KEY` environment variable (already in `.env`).

## Roast generator

Create a service that takes the computed workout stats and returns a funny roast string for each card (`summary`, `most_common_type`, `longest_workout`, `totals`).

Use `gpt-4o-mini` with temperature 0.9. Send a system prompt setting the tone ("savage but funny fitness roast comedian", 1-2 sentences max, punchy, brutal but not mean) and a user prompt with the actual stats. Request the response as JSON with exactly those 4 keys.

If the API fails or returns invalid JSON, return empty results — never crash. Cards should still display stats without roast text.

## Wire it in

After computing stats, call the roast generator and pass results to the view. Each card shows the roast quote above the stats.

## Verify

Run tests (mock the AI client — no real API calls in tests), then test the full flow in a browser.
