# Workshop Prompt: AI-Powered Roasts

## Prompt

Add OpenAI-powered roast text generation to the existing workout stats cards.

### Setup

Add the `ruby-openai` gem to the project. Store the OpenAI API key in Rails credentials:

```yaml
openai:
  api_key: <your_key>
```

### Roast generator service

Create a `RoastGeneratorService` that takes the stats hash from `WorkoutStatsService` and returns a hash of roast strings keyed by card type (`summary`, `most_common_type`, `longest_workout`, `totals`).

Use OpenAI's `gpt-4o-mini` model with temperature 0.9. Send two messages:

- **System prompt**: Tell the model it's a savage but funny fitness roast comedian. Roasts should be 1-2 sentences max, punchy, and hilarious - brutal but not mean-spirited. Instruct it to respond in valid JSON with exactly these keys: `summary`, `most_common_type`, `longest_workout`, `totals`. No markdown, no code blocks, just raw JSON.
- **User prompt**: Include the person's stats from the last 30 days - total workouts, total duration, favorite workout type with count and percentage, longest session details, total calories, total distance, and average heart rate. Ask for 4 specific roasts matching the card types.

Parse the JSON response and return a hash with symbol keys. If the API call fails or the response isn't valid JSON, log the error and return an empty hash - never raise.

### Wire it into the roast controller

In the `RoastsController#show` action, after computing stats, call the roast generator and pass the results to the view. Each card should display the roast text as a large quote above the stats. If no roast text is available for a card, just show the stats without it.

### Tests

Write tests for the roast generator service. Mock the OpenAI client - don't make real API calls in tests. Test the happy path (valid JSON response), error handling (API failure), and JSON parsing failure. Follow the existing test patterns in the project.

### Verify

Run `bin/rails test`, then start `bin/dev` and go through the full flow. Each card should now show a roast quote above the stats.
