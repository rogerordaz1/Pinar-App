-- supabase/migrations/20260521000000_initial_schema.sql

-- ============================================================
-- USUARIOS (extiende auth.users de Supabase)
-- ============================================================
create table public.users (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text unique not null,
  telefono    text,
  nombre      text,
  avatar_url  text,
  es_negocio  boolean not null default false,
  created_at  timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- CATEGORÍAS DE NEGOCIO
-- ============================================================
create table public.categorias_negocio (
  id      uuid primary key default gen_random_uuid(),
  nombre  text not null,
  icono   text,
  color   text
);

-- ============================================================
-- NEGOCIOS
-- ============================================================
create table public.negocios (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null references public.users(id) on delete cascade,
  nombre       text not null,
  descripcion  text,
  categoria_id uuid references public.categorias_negocio(id) on delete set null,
  logo_url     text,
  banner_url   text,
  direccion    text not null,
  ubicacion    geography(point, 4326) not null,
  provincia    text not null default 'pinar_del_rio',
  municipio    text,
  telefono     text,
  whatsapp     text,
  instagram    text,
  facebook     text,
  abierto      boolean not null default true,
  verificado   boolean not null default false,
  activo       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index negocios_ubicacion_idx on public.negocios using gist (ubicacion);
create index negocios_activo_idx on public.negocios (activo);

-- ============================================================
-- CATEGORÍAS DE PRODUCTO
-- ============================================================
create table public.categorias_producto (
  id      uuid primary key default gen_random_uuid(),
  nombre  text not null,
  icono   text
);

-- ============================================================
-- PRODUCTOS
-- ============================================================
create table public.productos (
  id                    uuid primary key default gen_random_uuid(),
  negocio_id            uuid not null references public.negocios(id) on delete cascade,
  nombre                text not null,
  descripcion           text,
  precio                decimal(10,2),
  moneda                text not null default 'cup',
  imagen_url            text,
  disponible            boolean not null default true,
  stock                 text check (stock in ('alto', 'medio', 'bajo', 'agotado')),
  ultima_actualizacion  timestamptz not null default now(),
  created_at            timestamptz not null default now()
);

create index productos_negocio_idx on public.productos (negocio_id);
create index productos_disponible_idx on public.productos (disponible);

-- ============================================================
-- PRODUCTO ↔ CATEGORÍA (muchos a muchos)
-- ============================================================
create table public.producto_categorias (
  producto_id  uuid not null references public.productos(id) on delete cascade,
  categoria_id uuid not null references public.categorias_producto(id),
  primary key (producto_id, categoria_id)
);

-- ============================================================
-- PLANES DE SUSCRIPCIÓN
-- ============================================================
create table public.planes_suscripcion (
  id                   uuid primary key default gen_random_uuid(),
  nombre               text not null check (nombre in ('basico', 'premium', 'vip')),
  precio_usd_mensual   decimal(6,2),
  precio_cup_mensual   decimal(10,2),
  max_productos        integer,
  destacado_busqueda   boolean not null default false,
  analytics            boolean not null default false,
  badge_verificado     boolean not null default false,
  publicidad_en_app    boolean not null default false,
  posicionamiento      integer not null default 3
);

insert into public.planes_suscripcion
  (nombre, max_productos, destacado_busqueda, analytics, badge_verificado, publicidad_en_app, posicionamiento)
values
  ('basico',  15,   false, false, false, false, 3),
  ('premium', 100,  true,  true,  false, false, 2),
  ('vip',     null, true,  true,  true,  true,  1);

-- ============================================================
-- SUSCRIPCIONES
-- ============================================================
create table public.suscripciones (
  id               uuid primary key default gen_random_uuid(),
  negocio_id       uuid not null references public.negocios(id) on delete cascade,
  plan_id          uuid not null references public.planes_suscripcion(id),
  estado           text not null check (estado in ('activa', 'vencida', 'cancelada', 'pendiente')),
  fecha_inicio     date not null,
  fecha_vencimiento date not null,
  metodo_pago      text check (metodo_pago in ('stripe', 'paypal', 'transfermovil', 'enzona', 'manual')),
  monto_pagado     decimal(8,2),
  moneda           text check (moneda in ('usd', 'cup')),
  referencia_pago  text,
  created_at       timestamptz not null default now()
);

-- ============================================================
-- VERIFICACIONES COMUNITARIAS
-- ============================================================
create table public.verificaciones (
  id          uuid primary key default gen_random_uuid(),
  producto_id uuid not null references public.productos(id) on delete cascade,
  usuario_id  uuid not null references public.users(id),
  tipo        text not null check (tipo in ('confirmado', 'reportado')),
  comentario  text,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- FAVORITOS
-- ============================================================
create table public.favoritos (
  usuario_id  uuid not null references public.users(id) on delete cascade,
  negocio_id  uuid not null references public.negocios(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (usuario_id, negocio_id)
);

-- ============================================================
-- RESEÑAS
-- ============================================================
create table public.resenas (
  id           uuid primary key default gen_random_uuid(),
  negocio_id   uuid not null references public.negocios(id) on delete cascade,
  usuario_id   uuid not null references public.users(id) on delete cascade,
  calificacion smallint not null check (calificacion between 1 and 5),
  comentario   text,
  created_at   timestamptz not null default now(),
  unique (negocio_id, usuario_id)
);

-- ============================================================
-- HORARIOS
-- ============================================================
create table public.horarios (
  negocio_id     uuid not null references public.negocios(id) on delete cascade,
  dia_semana     smallint not null check (dia_semana between 0 and 6),
  hora_apertura  time,
  hora_cierre    time,
  cerrado        boolean not null default false,
  primary key (negocio_id, dia_semana)
);

-- ============================================================
-- PROMOCIONES
-- ============================================================
create table public.promociones (
  id           uuid primary key default gen_random_uuid(),
  negocio_id   uuid not null references public.negocios(id) on delete cascade,
  titulo       text not null,
  descripcion  text,
  imagen_url   text,
  fecha_inicio date not null,
  fecha_fin    date not null,
  activa       boolean not null default true
);

-- ============================================================
-- FUNCIÓN: búsqueda de productos por nombre y proximidad
-- ============================================================
create or replace function public.buscar_producto_cercano(
  termino       text,
  lat           double precision,
  lng           double precision,
  radio_metros  double precision default 5000
)
returns table (
  negocio_id        uuid,
  negocio_nombre    text,
  negocio_direccion text,
  negocio_abierto   boolean,
  negocio_verificado boolean,
  producto_id       uuid,
  producto_nombre   text,
  producto_precio   decimal,
  producto_moneda   text,
  disponible        boolean,
  stock             text,
  ultima_actualizacion timestamptz,
  distancia_metros  double precision,
  calificacion      double precision
)
language sql stable as $$
  select
    n.id,
    n.nombre,
    n.direccion,
    n.abierto,
    n.verificado,
    p.id,
    p.nombre,
    p.precio,
    p.moneda,
    p.disponible,
    p.stock,
    p.ultima_actualizacion,
    st_distance(n.ubicacion, st_makepoint(lng, lat)::geography) as distancia_metros,
    coalesce(avg(r.calificacion), 0) as calificacion
  from public.productos p
  join public.negocios n on p.negocio_id = n.id
  left join public.resenas r on r.negocio_id = n.id
  where
    p.nombre ilike '%' || termino || '%'
    and p.disponible = true
    and n.activo = true
    and st_dwithin(n.ubicacion, st_makepoint(lng, lat)::geography, radio_metros)
  group by n.id, p.id
  order by distancia_metros asc;
$$;

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
alter table public.users enable row level security;
alter table public.negocios enable row level security;
alter table public.productos enable row level security;
alter table public.suscripciones enable row level security;
alter table public.favoritos enable row level security;
alter table public.resenas enable row level security;
alter table public.verificaciones enable row level security;

create policy "users_select_own" on public.users
  for select using (auth.uid() = id);
create policy "users_update_own" on public.users
  for update using (auth.uid() = id);

create policy "negocios_select_activos" on public.negocios
  for select using (activo = true);
create policy "negocios_insert_own" on public.negocios
  for insert with check (auth.uid() = owner_id);
create policy "negocios_update_own" on public.negocios
  for update using (auth.uid() = owner_id);

create policy "productos_select_disponibles" on public.productos
  for select using (
    exists (select 1 from public.negocios n where n.id = negocio_id and n.activo = true)
  );
create policy "productos_insert_owner" on public.productos
  for insert with check (
    exists (select 1 from public.negocios n where n.id = negocio_id and n.owner_id = auth.uid())
  );
create policy "productos_update_owner" on public.productos
  for update using (
    exists (select 1 from public.negocios n where n.id = negocio_id and n.owner_id = auth.uid())
  );
create policy "productos_delete_owner" on public.productos
  for delete using (
    exists (select 1 from public.negocios n where n.id = negocio_id and n.owner_id = auth.uid())
  );

create policy "favoritos_select_own" on public.favoritos
  for select using (auth.uid() = usuario_id);
create policy "favoritos_insert_own" on public.favoritos
  for insert with check (auth.uid() = usuario_id);
create policy "favoritos_delete_own" on public.favoritos
  for delete using (auth.uid() = usuario_id);

create policy "resenas_select_all" on public.resenas
  for select using (true);
create policy "resenas_insert_own" on public.resenas
  for insert with check (auth.uid() = usuario_id);
create policy "resenas_update_own" on public.resenas
  for update using (auth.uid() = usuario_id);

create policy "verificaciones_select_all" on public.verificaciones
  for select using (true);
create policy "verificaciones_insert_auth" on public.verificaciones
  for insert with check (auth.uid() = usuario_id);

create policy "suscripciones_select_owner" on public.suscripciones
  for select using (
    exists (select 1 from public.negocios n where n.id = negocio_id and n.owner_id = auth.uid())
  );

-- ============================================================
-- CATEGORÍAS DE DATOS INICIALES
-- ============================================================
insert into public.categorias_negocio (nombre, icono, color) values
  ('Agro / Frutas', 'agriculture', '#4CAF50'),
  ('Cafetería', 'coffee', '#795548'),
  ('Restaurante / Paladar', 'restaurant', '#FF5722'),
  ('Farmacia', 'medical_services', '#2196F3'),
  ('Ferretería', 'hardware', '#607D8B'),
  ('Tienda de ropa', 'checkroom', '#E91E63'),
  ('Bodega', 'store', '#FF9800'),
  ('Panadería', 'bakery_dining', '#FFC107'),
  ('Carnicería', 'set_meal', '#F44336'),
  ('Electrónica', 'devices', '#9C27B0'),
  ('Servicios', 'build', '#00BCD4'),
  ('Otro', 'category', '#9E9E9E');

insert into public.categorias_producto (nombre, icono) values
  ('Huevos', 'egg'),
  ('Aceite', 'water_drop'),
  ('Arroz', 'rice_bowl'),
  ('Frijoles', 'grass'),
  ('Pollo', 'set_meal'),
  ('Cerdo', 'lunch_dining'),
  ('Res', 'lunch_dining'),
  ('Pan', 'bakery_dining'),
  ('Leche', 'local_drink'),
  ('Café', 'coffee'),
  ('Azúcar', 'icecream'),
  ('Sal', 'water_drop'),
  ('Medicamentos', 'medication'),
  ('Higiene', 'soap'),
  ('Vegetales', 'eco'),
  ('Frutas', 'apple'),
  ('Bebidas', 'local_bar'),
  ('Otro', 'category');
