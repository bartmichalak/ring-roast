# Workshop Assumptions

## Open Wearables

Each team will work with their own Open Wearables instance hosted on Railway. All instances will be provisioned a few days before the hackathon. Access details (URLs, credentials) will be shared via Slack.

## Starter App

This repo serves as the starting point - a ready-to-run app that participants clone and build on top of during the workshop.

> **TODO:** Clean up `main` branch - the features built during the workshop are currently already implemented here. They need to be moved to separate branches so that `main` contains only the bare starter base.

### What's included out of the box

- **Docker Compose dev setup** - `cp .env.example .env && docker compose up` and you're running. No Ruby, no local dependencies.
- **Anonymous users** - each unique visitor automatically gets a user with a randomly generated Kahoot-style name (e.g. "FunkyPanda47"). Tracked via session cookie, no login required.
- **Vanilla fullstack Rails** - Rails 8, Hotwire (Turbo + Stimulus), Tailwind CSS, SQLite. Robust but lightweight - no Node.js, no external database, no complex infrastructure. Everything runs in a single container.

### What participants will build

The workshop is split into a few blocks, each adding a new integration on top of the starter:

1. **Connect Wearables** - integrate with the Open Wearables API to let users connect their devices via OAuth
2. **Workout Roast** - pull workout data from the Open Wearables API and display it
3. **OpenAI Roast** - use OpenAI to generate AI-powered roasts based on the workout data
4. **Sleep Roast** - pull sleep data from the Open Wearables API and roast users on their sleep habits
5. **Sleep Scores deep dive** - discussion on how sleep scores work under the hood - implementation details, design decisions, and comparison with provider-native scores (Whoop, Oura, Garmin, etc.)