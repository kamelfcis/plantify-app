-- Migration: Add tips and notification_id to reminders table
-- Run this in your Supabase SQL Editor if the reminders table already exists

-- Add tips column
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS tips TEXT;

-- Add notification_id column
ALTER TABLE public.reminders 
ADD COLUMN IF NOT EXISTS notification_id INTEGER;






