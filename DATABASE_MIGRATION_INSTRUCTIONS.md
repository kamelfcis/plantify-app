# Database Migration Instructions

## ⚠️ Error Fixed

**Error**: `Could not find the 'tips' column of 'reminders' in the schema cache`

This means your Supabase database table doesn't have the `tips` column yet.

## 🔧 Solution

You need to run a migration SQL script in your Supabase dashboard to add the missing columns.

### Step 1: Open Supabase Dashboard

1. Go to [https://supabase.com](https://supabase.com)
2. Log in to your account
3. Select your project

### Step 2: Open SQL Editor

1. Click on **"SQL Editor"** in the left sidebar
2. Click **"New query"**

### Step 3: Run Migration SQL

Copy and paste this SQL into the editor:

```sql
-- Add tips column if it doesn't exist
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS tips TEXT;

-- Add notification_id column if it doesn't exist
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS notification_id INTEGER;
```

### Step 4: Execute

1. Click **"Run"** or press `Ctrl+Enter` (Windows) / `Cmd+Enter` (Mac)
2. You should see "Success. No rows returned"

### Step 5: Verify

Run this query to verify the columns were added:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'reminders' 
AND column_name IN ('tips', 'notification_id');
```

You should see both `tips` and `notification_id` columns listed.

## ✅ After Migration

Once you've run the migration:

1. **Hot Restart** your Flutter app:
   ```bash
   flutter run
   ```

2. **Try creating a reminder again** - it should work now!

## 📝 Alternative: Run Full Schema

If you prefer, you can also run the complete updated schema from:
- `supabase/schema.sql` (updated version with tips column)

But the migration above is simpler and safer if you already have data in your reminders table.

## 🚀 Quick Copy-Paste SQL

Here's the complete SQL to copy:

```sql
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS tips TEXT;

ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS notification_id INTEGER;
```

That's it! Just run these two lines in Supabase SQL Editor.






