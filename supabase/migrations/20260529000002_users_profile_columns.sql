-- supabase/migrations/20260529000002_users_profile_columns.sql

alter table public.users
  add column if not exists direccion text,
  add column if not exists lat       double precision,
  add column if not exists lng       double precision;
