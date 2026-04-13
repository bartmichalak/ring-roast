# Objective: Connect Wearables

**Expected time: 15 minutes**

https://github.com/user-attachments/assets/d34f6129-8000-4a8f-851c-d941729bbe91

## What you'll learn about Open Wearables

In this part of the workshop, you'll integrate your app with the Open Wearables platform. Instead of building separate integrations for Garmin, Whoop, Oura, Polar, Strava, and others - you'll use a single API to connect them all. This is what a unified API looks like in practice.

You'll go through seven core steps:

1. **Logging into your Open Wearables instance** - Each team will receive a link to their own Open Wearables instance before the hackathon starts. Log in and explore the dashboard.

2. **Generating an API key** - Create an API key in the Open Wearables dashboard and configure it in your app's Rails credentials.

3. **Creating users via the API** - Register this app's users with Open Wearables so they can connect their devices. Each user gets a UUID that links your local database to the platform.

4. **Fetching available providers** - Query the API to get a list of supported wearable providers, complete with their names and icons, and display them in your app.

5. **Running the OAuth connect flow** - Initiate the authorization flow for a chosen provider, redirect the user to authenticate with their wearable account, and handle the callback to verify the connection was established.

6. **Connecting Apple Health data** - Use the Open Wearables companion app to sync Apple Health data from your phone. ([Docs](https://openwearables.io/docs/app/introduction))

7. **Data coverage across providers** - Discussion on the differences in what data each wearable provider returns. Not all providers support the same data types - some have detailed sleep stages, others don't expose HRV, recovery scores vary wildly. We'll walk through the [provider coverage matrix](https://openwearables.io/docs/providers/coverage) to understand what to expect from each integration.

## No wearable data? No problem

If you don't have any data in your wearable (or don't own one), you can use the **seed data generator** in the Open Wearables dashboard to populate sample health data. This lets you test the full flow without needing a real device.

By the end, you'll have a working integration where users can connect their wearable device in just a few clicks - without dealing with individual provider APIs, OAuth implementations, or data format differences.
