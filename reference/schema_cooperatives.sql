-- =========================================================
-- UNIVO COOPERATIVE SOCIETIES SCHEMA
-- Tables: public.cooperatives, public.cooperative_passport_requests
-- =========================================================

-- 1. Cooperatives Directory Table
create table if not exists public.cooperatives (
    id uuid default gen_random_uuid() primary key,
    auth_user_id uuid references auth.users(id) on delete cascade,
    cooperative_name text not null,
    registration_number text not null unique,
    district text not null,
    zone text not null,
    cooperative_type text default 'Multi-Purpose Skills Cooperative',
    coordinator_name text not null,
    phone text not null,
    email text not null unique,
    registered_workers_count integer default 0,
    active_dispatches_count integer default 0,
    status text default 'verified_active',
    metadata jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Enable Row Level Security (RLS)
alter table public.cooperatives enable row level security;

create policy "Allow read access to cooperatives"
    on public.cooperatives
    for select
    using (true);

create policy "Allow insert access to cooperatives"
    on public.cooperatives
    for insert
    with check (true);

create policy "Allow update access to own cooperative"
    on public.cooperatives
    for update
    using (auth.uid() = auth_user_id or auth.uid() is null);

-- Trigger for updated_at
create or replace function public.handle_cooperatives_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists tr_cooperatives_updated_at on public.cooperatives;
create trigger tr_cooperatives_updated_at
    before update on public.cooperatives
    for each row
    execute function public.handle_cooperatives_updated_at();

-- Sample seed cooperatives for demonstration
insert into public.cooperatives (
    cooperative_name, 
    registration_number, 
    district, 
    zone, 
    cooperative_type, 
    coordinator_name, 
    phone, 
    email, 
    registered_workers_count, 
    active_dispatches_count
)
values
('Chennai Metro Technical & Artisans Cooperative Society', 'TN/COOP/CHE/2024/091', 'Chennai', 'Zone 9 - Teynampet', 'Electrical & Technical Workers Society', 'R. Meenakshi Sundaram', '+91 98401 22910', 'chennai.metro@univo-coop.org', 142, 18),
('Kovai Industrial Skills & Allied Welfare Union', 'TN/COOP/CBE/2023/118', 'Coimbatore', 'Coimbatore South', 'Construction & Fabrication Cooperative', 'K. Murugesan', '+91 97910 88412', 'kovai.workers@univo-coop.org', 98, 12),
('Madurai Regional Labor & Craft Guild', 'TN/COOP/MDU/2024/045', 'Madurai', 'Madurai South', 'Multi-Purpose Skills Cooperative', 'S. Muthulakshmi', '+91 94441 77320', 'madurai.guild@univo-coop.org', 115, 14)
on conflict (registration_number) do nothing;


-- 2. Worker Passport Accreditation Requests Table
-- Routes worker passport approval requests to specific cooperative district and zone
create table if not exists public.cooperative_passport_requests (
    id uuid default gen_random_uuid() primary key,
    worker_id text not null,
    worker_name text not null,
    worker_email text not null,
    worker_phone text,
    passport_id text not null,
    trade_sector text not null,
    experience_years text,
    district text not null,
    zone text not null,
    cooperative_name text,
    qualification_score text default '15 / 15 Sections',
    status text default 'PENDING_APPROVAL', -- 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'
    approved_by text,
    approved_at timestamptz,
    rejection_reason text,
    passport_data jsonb default '{}'::jsonb,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Enable RLS
alter table public.cooperative_passport_requests enable row level security;

create policy "Allow read access to cooperative_passport_requests"
    on public.cooperative_passport_requests
    for select
    using (true);

create policy "Allow insert access to cooperative_passport_requests"
    on public.cooperative_passport_requests
    for insert
    with check (true);

create policy "Allow update access to cooperative_passport_requests"
    on public.cooperative_passport_requests
    for update
    using (true);

drop trigger if exists tr_coop_passport_requests_updated_at on public.cooperative_passport_requests;
create trigger tr_coop_passport_requests_updated_at
    before update on public.cooperative_passport_requests
    for each row
    execute function public.handle_cooperatives_updated_at();

-- Sample seed requests for demonstration
insert into public.cooperative_passport_requests (
    worker_id, worker_name, worker_email, worker_phone, passport_id, trade_sector, experience_years, district, zone, cooperative_name, status
)
values
('wrk_sundaram', 'M. Sundaram', 'sundaram.plumb@gmail.com', '+91 97910 44821', '#UNV-WRK-2026-0812', 'Plumbing & Drainage Solutions', '11 Years', 'Chennai', 'Zone 9 - Teynampet', 'Chennai Metro Technical & Artisans Cooperative Society', 'PENDING_APPROVAL'),
('wrk_karthik', 'R. Karthik', 'karthik.spark@gmail.com', '+91 98402 11928', '#UNV-WRK-2026-0984', 'Electrical & Wiring Installation', '8 Years', 'Chennai', 'Zone 9 - Teynampet', 'Chennai Metro Technical & Artisans Cooperative Society', 'PENDING_APPROVAL'),
('wrk_anandhan', 'P. Anandhan', 'anandhan.carp@gmail.com', '+91 94441 55210', '#UNV-WRK-2026-1045', 'Carpentry, Joinery & Furniture Restoration', '14 Years', 'Coimbatore', 'Coimbatore South', 'Kovai Industrial Skills & Allied Welfare Union', 'PENDING_APPROVAL')
on conflict do nothing;


-- =========================================================
-- 3. CUSTOMER SOS EMERGENCY ALERTS TABLE
-- Dispatches distress signals to emergency contacts & cooperatives
-- =========================================================
create table if not exists public.sos_emergency_alerts (
    id uuid default gen_random_uuid() primary key,
    alert_code text not null, -- e.g. '#UNV-SOS-9821'
    customer_id uuid,
    customer_name text not null,
    customer_email text,
    customer_phone text,
    emergency_contact_name text,
    emergency_contact_phone text,
    emergency_type text default 'General Safety & Panic SOS',
    status text default 'ACTIVE_DISPATCHED', -- 'ACTIVE_DISPATCHED', 'ACKNOWLEDGED', 'RESOLVED', 'CANCELLED'
    latitude numeric,
    longitude numeric,
    location_address text,
    cooperative_id uuid,
    cooperative_name text default 'Chennai Metro Technical & Artisans Cooperative Society',
    cooperative_phone text default '+91 98401 22910',
    contact_message_status text default 'SENT_PRIORITY',
    cooperative_message_status text default 'FORWARDED_ACTIVE',
    alert_notes text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Enable RLS
alter table public.sos_emergency_alerts enable row level security;

create policy "Allow read access to sos_emergency_alerts"
    on public.sos_emergency_alerts
    for select
    using (true);

create policy "Allow insert access to sos_emergency_alerts"
    on public.sos_emergency_alerts
    for insert
    with check (true);

create policy "Allow update access to sos_emergency_alerts"
    on public.sos_emergency_alerts
    for update
    using (true);

-- Indexes
create index if not exists idx_sos_alerts_status on public.sos_emergency_alerts(status);
create index if not exists idx_sos_alerts_customer_id on public.sos_emergency_alerts(customer_id);
create index if not exists idx_sos_alerts_cooperative_name on public.sos_emergency_alerts(cooperative_name);

drop trigger if exists tr_sos_emergency_alerts_updated_at on public.sos_emergency_alerts;
create trigger tr_sos_emergency_alerts_updated_at
    before update on public.sos_emergency_alerts
    for each row
    execute function public.handle_cooperatives_updated_at();

