# Workshop: From Zero to Wearable Data in 60 Minutes

## Prerequisites

- **Docker** installed and running
- **Claude Code** (or another AI coding agent)
- Access to your team's Open Wearables instance (URL + credentials shared before the hackathon)

## Pre-Workshop Setup (do this BEFORE the workshop starts)

### 1. Clone the repo and configure environment

```bash
git clone https://github.com/bartmichalak/ring-roast.git
cd ring-roast
cp .env.example .env
```

Edit `.env` and fill in your credentials:

```
OPEN_WEARABLES_API_KEY=your_key_from_ow_dashboard
OPEN_WEARABLES_API_URL=https://your-team-instance.up.railway.app
OPENAI_API_KEY=your_openai_key
```

### 2. Start the app

```bash
docker compose up
```

The app will be available at **http://localhost:3100**. First build takes a few minutes.

### 3. Verify it works

Open http://localhost:3100 — you should see the Ring Roast landing page with a disabled "Connect Your Wearable" button.

## Open Wearables

Each team has their own Open Wearables instance hosted on Railway, provisioned before the hackathon. Log into your instance, explore the dashboard, and grab your API key from the settings tab.

**No wearable data?** Use the **seed data generator** in the OW dashboard to populate sample health data.

## Starter App

This repo (`workshop-base` branch) is the starting point — a ready-to-run app that participants build on during the workshop.

### What's included out of the box

- **Docker Compose dev setup** — `cp .env.example .env && docker compose up` and you're running. No Ruby, no local dependencies.
- **Anonymous users** — each visitor automatically gets a user with a randomly generated Kahoot-style name (e.g. "FunkyPanda47"). Tracked via session cookie, no login required.
- **Vanilla fullstack Rails** — Rails 8, Hotwire (Turbo + Stimulus), Tailwind CSS, SQLite. Everything runs in a single container.

### Running commands

Since the dev environment runs in Docker, prefix all Rails commands:

```bash
docker compose exec web bin/rails test          # Run tests
docker compose exec web bin/rails db:migrate    # Run migrations
docker compose exec web bundle install          # Install gems
```

## API Reference

See [`ow-integration-reference.md`](./ow-integration-reference.md) for Open Wearables documentation status and known gaps.
