-- WAKHAMA DISTRIBUTOR SUPABASE SETUP
-- Run this whole file in Supabase Dashboard -> SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  phone text,
  role text not null default 'artist' check (role in ('artist','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.songs (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.profiles(id) on delete cascade,
  artist_name text not null,
  song_title text not null,
  genre text not null,
  release_date date,
  audio_url text not null,
  cover_url text not null,
  payment_tx_ref text,
  payment_status text not null default 'Pending' check (payment_status in ('Pending','Verified','Rejected')),
  status text not null default 'Pending' check (status in ('Pending','Approved','Rejected')),
  streams bigint not null default 0,
  earnings_mwk numeric(14,2) not null default 0,
  spotify_status text not null default 'Not submitted',
  spotify_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.withdrawals (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.profiles(id) on delete cascade,
  phone text not null,
  provider text not null check(provider in ('Airtel Money','TNM Mpamba')),
  amount numeric(14,2) not null check(amount >= 1000),
  status text not null default 'Pending' check(status in ('Pending','Paid','Rejected')),
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.profiles(id) on delete cascade,
  song_id uuid references public.songs(id) on delete cascade,
  amount numeric(14,2) not null default 5000,
  provider text not null default 'Mobile Money',
  reference text,
  status text not null default 'Pending' check(status in ('Pending','Verified','Rejected')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.songs enable row level security;
alter table public.withdrawals enable row level security;
alter table public.payments enable row level security;

-- Profile trigger
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,name,phone)
  values(new.id,new.raw_user_meta_data->>'name',new.raw_user_meta_data->>'phone')
  on conflict(id) do update set name=excluded.name,phone=excluded.phone;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users for each row execute procedure public.handle_new_user();

-- RLS policies
drop policy if exists "profiles own select" on public.profiles;
create policy "profiles own select" on public.profiles for select using (auth.uid()=id);

drop policy if exists "songs public approved" on public.songs;
create policy "songs public approved" on public.songs for select using (status='Approved' or auth.uid()=artist_id);

drop policy if exists "artists insert songs" on public.songs;
create policy "artists insert songs" on public.songs for insert with check (auth.uid()=artist_id);

drop policy if exists "artists own update songs" on public.songs;
create policy "artists own update songs" on public.songs for update using (auth.uid()=artist_id);

drop policy if exists "own withdrawals select" on public.withdrawals;
create policy "own withdrawals select" on public.withdrawals for select using (auth.uid()=artist_id);

drop policy if exists "own payments select" on public.payments;
create policy "own payments select" on public.payments for select using (auth.uid()=artist_id);

-- Record one stream safely through RPC.
create or replace function public.record_stream(song_uuid uuid)
returns void language plpgsql security definer set search_path=public as $$
begin
  update public.songs
  set streams=streams+1,
      earnings_mwk=earnings_mwk+1
  where id=song_uuid and status='Approved';
end $$;

-- Dashboard for logged-in artist.
create or replace function public.artist_dashboard()
returns table(total_streams bigint,total_earnings numeric,pending_withdrawal numeric,available_balance numeric)
language sql security definer set search_path=public as $$
  with s as (
    select coalesce(sum(streams),0) streams,coalesce(sum(earnings_mwk),0) earnings
    from public.songs where artist_id=auth.uid()
  ), w as (
    select coalesce(sum(amount),0) pending
    from public.withdrawals where artist_id=auth.uid() and status='Pending'
  ), paid as (
    select coalesce(sum(amount),0) paid
    from public.withdrawals where artist_id=auth.uid() and status='Paid'
  )
  select s.streams,s.earnings,w.pending,greatest(0,s.earnings-w.pending-paid.paid)
  from s,w,paid;
$$;

create or replace function public.request_withdrawal(p_phone text,p_provider text,p_amount numeric)
returns uuid language plpgsql security definer set search_path=public as $$
declare bal numeric; wid uuid;
begin
  select available_balance into bal from public.artist_dashboard();
  if p_amount < 1000 then raise exception 'Minimum withdrawal ndi K1000'; end if;
  if p_amount > bal then raise exception 'Available balance siyokwanira'; end if;
  insert into public.withdrawals(artist_id,phone,provider,amount)
  values(auth.uid(),p_phone,p_provider,p_amount) returning id into wid;
  return wid;
end $$;

-- Storage buckets
insert into storage.buckets(id,name,public) values('music','music',true)
on conflict(id) do update set public=true;
insert into storage.buckets(id,name,public) values('covers','covers',true)
on conflict(id) do update set public=true;

-- Storage policies: logged-in artists may upload into their own folder.
drop policy if exists "music upload own folder" on storage.objects;
create policy "music upload own folder" on storage.objects for insert to authenticated
with check(bucket_id='music' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists "covers upload own folder" on storage.objects;
create policy "covers upload own folder" on storage.objects for insert to authenticated
with check(bucket_id='covers' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists "music public read" on storage.objects;
create policy "music public read" on storage.objects for select using(bucket_id='music');

drop policy if exists "covers public read" on storage.objects;
create policy "covers public read" on storage.objects for select using(bucket_id='covers');

-- NOTE:
-- For admin controls, use a secure admin dashboard/server using the Supabase service role.
-- Do NOT put the service-role key in this index.html or any browser code.
-- K5,000 payment verification and Mobile Money payout should be connected to the
-- actual Airtel Money/TNM Mpamba merchant/API before calling them automatic.
