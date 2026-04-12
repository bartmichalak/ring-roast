# Objective: Workout Roast

**Expected time: 20 minutes**

**Demo:** [Watch the outcome](../../videos/02-workout-roast.mp4)

## What you'll learn about Open Wearables

In this part of the workshop, you'll pull actual health data from the Open Wearables API and turn it into a Spotify Wrapped-style presentation. This is where the "roast" comes to life.

You'll go through three core steps:

1. **Fetching workout data from the API** - Use the workouts endpoint to pull all workout sessions from the last 30 days. The API returns structured data including workout type, duration, calories, distance, and heart rate - all normalized across providers.

2. **Computing interesting stats** - Build a service that crunches the raw data into card-worthy facts: total workouts, most common workout type, longest session, total calories and distance.

3. **Building a fullscreen card presentation** - Create a Spotify Wrapped-style experience with bold, colorful fullscreen cards that users navigate with arrow keys or swipe. Each card highlights a different stat.

## What makes this interesting

The Open Wearables API normalizes data from different providers into a consistent format. Whether the user connected Garmin, Whoop, or Apple Health - the workout data comes back in the same shape. You don't need to handle provider-specific quirks.

The API also handles pagination automatically - if a user has many workouts, you'll use cursor-based pagination to fetch them all.

## What's next

In a later step, we'll integrate OpenAI to generate funny roast text for each card based on the stats. For now, we're focusing on getting the data right and making the presentation look great.
