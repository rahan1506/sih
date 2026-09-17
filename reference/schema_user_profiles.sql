-- ==========================================================
-- UNIVO CUSTOMER / USER PROFILES SCHEMA
-- Target Table: public.user_profiles
-- Run this in your Supabase SQL Editor
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    email TEXT NOT NULL,
    first_name TEXT DEFAULT '',
    last_name TEXT DEFAULT '',
    full_name TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    emergency_contact_name TEXT DEFAULT '',
    emergency_contact_phone TEXT DEFAULT '',
    avatar_url TEXT,
    saved_locations JSONB DEFAULT '[]'::jsonb,
    favorite_workers JSONB DEFAULT '[]'::jsonb,
    notification_preferences JSONB DEFAULT '{"email": true, "sms": true, "whatsapp": true}'::jsonb,
    language_preference TEXT DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for rapid lookup
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Allow public / anon read and upsert for the UNIVO client application
CREATE POLICY "Allow public read of user profiles" 
ON public.user_profiles FOR SELECT USING (true);

CREATE POLICY "Allow insert of user profiles" 
ON public.user_profiles FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update of user profiles" 
ON public.user_profiles FOR UPDATE USING (true);

CREATE POLICY "Allow delete of user profiles" 
ON public.user_profiles FOR DELETE USING (true);
