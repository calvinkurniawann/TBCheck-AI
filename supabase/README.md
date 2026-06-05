# Supabase Setup

Use `setup.sql` in the Supabase SQL editor.

## What this sets up
- `screening_histories` table for app history
- row level security policies
- `calculate_screening(selected_symptoms text[])` RPC

## App config
- `supabaseUrl`: `https://ggfqookfzpafrjekjerg.supabase.co`
- `supabaseAnonKey`: your publishable key

## Important
- The app uses Supabase Auth, not the legacy Laravel `users` table.
- `screening_histories.user_id` is stored as `text` and compared to `auth.uid()::text`.
- Keep Email auth enabled in Supabase Authentication.

## Run order
1. Paste and run `setup.sql`
2. Confirm Email auth is enabled
3. Rebuild the Flutter app
