-- ====================================================
-- MIGRATION: Add tips and notification_id to reminders table
-- ====================================================
-- Run this SQL in your Supabase SQL Editor
-- This adds the missing 'tips' and 'notification_id' columns

-- Add tips column if it doesn't exist
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS tips TEXT;

-- Add notification_id column if it doesn't exist
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS notification_id INTEGER;

-- Verify the columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'reminders' 
AND column_name IN ('tips', 'notification_id');






