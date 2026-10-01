-- ==============================================================================
-- OMath Game: Supabase Schema & Leaderboard Setup
-- Run this script in the Supabase SQL Editor:
-- https://supabase.com/dashboard/project/cvzwzjfxtclyninxviat/sql/new
-- ==============================================================================

-- 1. Create profiles table
create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  username text not null default 'Player',
  avatar_id integer not null default 0,
  total_xp integer not null default 0,
  coin_balance integer not null default 100,
  login_streak integer not null default 1,
  last_login timestamptz default timezone('utc'::text, now()),
  last_share_date timestamptz,
  created_at timestamptz default timezone('utc'::text, now()) not null,
  updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- 2. Create index for fast leaderboard ranking
create index if not exists idx_profiles_total_xp on public.profiles (total_xp desc);
create index if not exists idx_profiles_username on public.profiles (username);

-- 3. Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- 4. Set up RLS Policies
-- Allow anyone (including anonymous users and unauthenticated guests) to read profiles for the leaderboard
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

-- Allow authenticated and anonymous users to insert their own profile
drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() is null or auth.uid() = id);

-- Allow authenticated and anonymous users to update their own profile
drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() is null or auth.uid() = id);

-- 5. Auto-sync trigger for new auth signups (optional automatic profile creation)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, avatar_id, total_xp, coin_balance, login_streak, last_login)
  values (
    new.id,
    'Player ' || upper(substr(new.id::text, 1, 4)),
    floor(random() * 6)::integer,
    0,
    100,
    1,
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 6. Insert initial seed leaderboard players (so the leaderboard is alive immediately)
insert into public.profiles (id, username, avatar_id, total_xp, coin_balance, login_streak)
values
  ('00000000-0000-0000-0000-000000000001', 'MathWizard', 5, 2850, 450, 14),
  ('00000000-0000-0000-0000-000000000002', 'Brainiac_99', 3, 2420, 380, 10),
  ('00000000-0000-0000-0000-000000000003', 'NumberNinja', 8, 2190, 310, 9),
  ('00000000-0000-0000-0000-000000000004', 'EulerPrime', 12, 1850, 260, 7),
  ('00000000-0000-0000-0000-000000000005', 'MatrixMaster', 2, 1640, 220, 6),
  ('00000000-0000-0000-0000-000000000006', 'QuickSolver', 15, 1420, 190, 5),
  ('00000000-0000-0000-0000-000000000007', 'Pythagoras', 4, 1250, 170, 4),
  ('00000000-0000-0000-0000-000000000008', 'QuantumMind', 7, 980, 140, 3),
  ('00000000-0000-0000-0000-000000000009', 'CosmicMath', 1, 750, 120, 2),
  ('00000000-0000-0000-0000-000000000010', 'ApexLogic', 10, 520, 100, 1)
on conflict (id) do nothing;
