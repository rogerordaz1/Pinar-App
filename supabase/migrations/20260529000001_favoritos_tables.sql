-- supabase/migrations/20260529000001_favoritos_tables.sql

create table public.negocios_favoritos (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  negocio_id uuid not null,
  created_at timestamptz default now(),
  unique (user_id, negocio_id)
);
alter table public.negocios_favoritos enable row level security;
create policy "usuario ve sus favoritos" on public.negocios_favoritos
  for all using (auth.uid() = user_id);

create table public.productos_favoritos (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  producto_id uuid not null,
  negocio_id  uuid not null,
  created_at  timestamptz default now(),
  unique (user_id, producto_id)
);
alter table public.productos_favoritos enable row level security;
create policy "usuario ve sus favoritos" on public.productos_favoritos
  for all using (auth.uid() = user_id);
