-- ==========================================================
-- UNIVO WORKER PASSPORT & COOPERATIVE VERIFICATION SCHEMA
-- Target Table: public.worker_passports
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.worker_passports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_id TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    full_name TEXT NOT NULL,
    
    -- 1. Personal Information
    personal_info JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 2. Location
    location_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 3. Identity Verification
    identity_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 4. Primary Profession
    primary_profession JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 5. Skills
    skills_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 6. Certifications
    certifications_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 7. Work Experience
    experience_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 8. Service Capability
    service_capability JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 9. Availability
    availability_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 10. Languages
    languages_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 11. Pricing
    pricing_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 12. Documents
    documents_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 13. Emergency Contact
    emergency_contact JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 14. Payment Details (Secured)
    payment_details JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 15. Profile Verification & Cooperative Status
    verification_status JSONB NOT NULL DEFAULT '{}'::jsonb,
    cooperative_name TEXT DEFAULT 'Chennai Central Artisan & Technicians Welfare Co-operative Society #TN-COOP-410',
    cooperative_status TEXT DEFAULT 'PENDING_COOPERATIVE_APPROVAL', -- 'PENDING_COOPERATIVE_APPROVAL' | 'APPROVED' | 'REJECTED'
    approved_by TEXT,
    approved_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for lightning queries
CREATE INDEX IF NOT EXISTS idx_worker_passports_email ON public.worker_passports(email);
CREATE INDEX IF NOT EXISTS idx_worker_passports_worker_id ON public.worker_passports(worker_id);
CREATE INDEX IF NOT EXISTS idx_worker_passports_status ON public.worker_passports(cooperative_status);

-- Enable Row Level Security (RLS)
ALTER TABLE public.worker_passports ENABLE ROW LEVEL SECURITY;

-- Allow public / anon read and upsert for the UNIVO client application
CREATE POLICY "Allow public read of worker passports" 
ON public.worker_passports FOR SELECT USING (true);

CREATE POLICY "Allow insert of worker passports" 
ON public.worker_passports FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update of worker passports" 
ON public.worker_passports FOR UPDATE USING (true);
