# Objective: AI-Powered Roasts

**Expected time: 10 minutes**

## What you'll build

In this part of the workshop, you'll add the "roast" to Ring Roast. The fullscreen cards from the previous step already show workout stats - now you'll feed those stats to OpenAI and get back short, punchy, hilarious roast texts for each card.

You'll go through three core steps:

1. **Setting up the OpenAI integration** - Add the `ruby-openai` gem and configure your API key in Rails credentials.

2. **Building a roast generator service** - Create a service that sends the computed workout stats to OpenAI's `gpt-4o-mini` model and parses the structured JSON response back into per-card roast strings.

3. **Displaying roasts on the cards** - Wire the generated roast text into the fullscreen presentation so each card shows a roast quote alongside its stats.

## How the roast generation works

The service sends two messages to OpenAI:

- A **system prompt** that sets the tone: "You are a savage but funny fitness roast comedian." It also instructs the model to respond in JSON with exactly 4 keys matching the card types.
- A **user prompt** that includes the person's actual stats - workout count, favorite type, longest session, calories, distance, and heart rate.

The model runs at temperature 0.9 for creative, varied output. Each request generates all 4 roasts in a single API call.

## Graceful degradation

If OpenAI is unavailable or returns invalid JSON, the service returns an empty hash and the cards still display stats without roast text. The app never crashes due to an AI failure.
