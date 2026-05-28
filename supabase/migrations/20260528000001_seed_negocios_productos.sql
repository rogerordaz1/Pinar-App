-- ================================================================
-- SEED: negocios, productos, promociones y RPCs para home screen
-- Ejecutar en Supabase SQL Editor (service role)
-- ================================================================

-- ── 1. Ajustes de schema ──────────────────────────────────────

ALTER TABLE public.productos
  ADD COLUMN IF NOT EXISTS unidad text NOT NULL DEFAULT 'unidad';

-- calificacion_cache permite mostrar una calificación base hasta
-- que lleguen reseñas reales de usuarios.
ALTER TABLE public.negocios
  ADD COLUMN IF NOT EXISTS calificacion_cache decimal(3,1) NOT NULL DEFAULT 4.0;

-- ── 2. RPCs para el home screen ───────────────────────────────

CREATE OR REPLACE FUNCTION public.get_negocios_home(
  lat double precision DEFAULT 22.4164,
  lng double precision DEFAULT -83.6964
)
RETURNS TABLE (
  id           text,
  nombre       text,
  categoria    text,
  abierto      boolean,
  logo_url     text,
  verificado   boolean,
  calificacion double precision,
  distancia_km double precision
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    n.id::text,
    n.nombre,
    COALESCE(c.nombre, 'Otro'),
    n.abierto,
    n.logo_url,
    n.verificado,
    COALESCE(
      AVG(r.calificacion)::double precision,
      n.calificacion_cache::double precision,
      0.0
    ),
    (ST_Distance(
      n.ubicacion::geography,
      ST_MakePoint(lng, lat)::geography
    ) / 1000.0)::double precision
  FROM public.negocios n
  LEFT JOIN public.categorias_negocio c ON n.categoria_id = c.id
  LEFT JOIN public.resenas r ON r.negocio_id = n.id
  WHERE n.activo = true
  GROUP BY n.id, c.nombre
  ORDER BY ST_Distance(
    n.ubicacion::geography,
    ST_MakePoint(lng, lat)::geography
  ) ASC
  LIMIT 20;
$$;

CREATE OR REPLACE FUNCTION public.get_productos_populares()
RETURNS TABLE (
  id             text,
  nombre         text,
  precio         double precision,
  unidad         text,
  negocio_nombre text,
  negocio_id     text,
  disponible     boolean,
  imagen_url     text
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.id::text,
    p.nombre,
    p.precio::double precision,
    p.unidad,
    n.nombre AS negocio_nombre,
    p.negocio_id::text,
    p.disponible,
    p.imagen_url
  FROM public.productos p
  JOIN public.negocios n ON p.negocio_id = n.id
  WHERE p.disponible = true AND n.activo = true
  ORDER BY p.created_at DESC
  LIMIT 15;
$$;

CREATE OR REPLACE FUNCTION public.get_promociones_home()
RETURNS TABLE (
  id             text,
  titulo         text,
  imagen_url     text,
  negocio_id     text,
  nombre_negocio text
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    pr.id::text,
    pr.titulo,
    pr.imagen_url,
    pr.negocio_id::text,
    n.nombre AS nombre_negocio
  FROM public.promociones pr
  JOIN public.negocios n ON pr.negocio_id = n.id
  WHERE pr.activa = true
    AND pr.fecha_fin >= CURRENT_DATE
  ORDER BY pr.fecha_inicio DESC
  LIMIT 5;
$$;

GRANT EXECUTE ON FUNCTION public.get_negocios_home(double precision, double precision) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_productos_populares() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_promociones_home() TO authenticated, anon;
GRANT SELECT ON public.categorias_negocio TO authenticated, anon;

-- ── 3. Usuario propietario de seed ───────────────────────────

INSERT INTO auth.users (
  instance_id, id, aud, role, email,
  encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at,
  confirmation_token, recovery_token,
  email_change_token_new, email_change
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  'b0000000-0000-0000-0000-000000000001',
  'authenticated', 'authenticated',
  'seed@pinarmarket.cu',
  crypt('SeedPinar2026!', gen_salt('bf', 10)),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"nombre":"Propietario Seed"}',
  NOW(), NOW(),
  '', '', '', ''
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.users (id, email, nombre)
VALUES ('b0000000-0000-0000-0000-000000000001', 'seed@pinarmarket.cu', 'Propietario Seed')
ON CONFLICT (id) DO NOTHING;

-- ── 4. Negocios (20) ──────────────────────────────────────────

INSERT INTO public.negocios (
  id, owner_id, nombre, categoria_id,
  logo_url, banner_url,
  direccion, ubicacion, municipio,
  telefono, whatsapp,
  abierto, verificado, calificacion_cache
) VALUES

-- 1 · La Panadería Elena
('a0000000-0000-0000-0000-000000000001',
 'b0000000-0000-0000-0000-000000000001',
 'La Panadería Elena',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Panadería'),
 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800&h=300&fit=crop&auto=format',
 'Calle Martí 23, Centro', ST_SetSRID(ST_MakePoint(-83.6931,22.4183),4326)::geography,
 'Pinar del Río', '+5348111001', '+5358111001',
 true, true, 4.9),

-- 2 · Agro San Cristóbal
('a0000000-0000-0000-0000-000000000002',
 'b0000000-0000-0000-0000-000000000001',
 'Agro San Cristóbal',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Agro / Frutas'),
 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1500651230702-0e2d8a49d4ad?w=800&h=300&fit=crop&auto=format',
 'Ave. Comandante Pinares, km 2', ST_SetSRID(ST_MakePoint(-83.6880,22.4210),4326)::geography,
 'Pinar del Río', '+5348111002', '+5358111002',
 false, false, 4.5),

-- 3 · Farmacia Vida
('a0000000-0000-0000-0000-000000000003',
 'b0000000-0000-0000-0000-000000000001',
 'Farmacia Vida',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Farmacia'),
 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&h=300&fit=crop&auto=format',
 'Calle Isabel Rubio 45', ST_SetSRID(ST_MakePoint(-83.6840,22.4130),4326)::geography,
 'Pinar del Río', '+5348111003', '+5358111003',
 true, true, 4.8),

-- 4 · Cafetería El Patio
('a0000000-0000-0000-0000-000000000004',
 'b0000000-0000-0000-0000-000000000001',
 'Cafetería El Patio',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Cafetería'),
 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800&h=300&fit=crop&auto=format',
 'Calle Gerardo Medina 12', ST_SetSRID(ST_MakePoint(-83.7010,22.4190),4326)::geography,
 'Pinar del Río', '+5348111004', '+5358111004',
 true, false, 4.7),

-- 5 · Bodega La Confianza
('a0000000-0000-0000-0000-000000000005',
 'b0000000-0000-0000-0000-000000000001',
 'Bodega La Confianza',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Bodega'),
 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1553073520-80b5ad5e2b4a?w=800&h=300&fit=crop&auto=format',
 'Reparto La Coloma, Bloque 3', ST_SetSRID(ST_MakePoint(-83.6990,22.4095),4326)::geography,
 'Pinar del Río', '+5348111005', NULL,
 true, false, 4.3),

-- 6 · Ferretería Central
('a0000000-0000-0000-0000-000000000006',
 'b0000000-0000-0000-0000-000000000001',
 'Ferretería Central',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Ferretería'),
 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=800&h=300&fit=crop&auto=format',
 'Calle Frank País 88', ST_SetSRID(ST_MakePoint(-83.7045,22.4220),4326)::geography,
 'Pinar del Río', '+5348111006', '+5358111006',
 false, true, 4.6),

-- 7 · Paladar La Pinareña
('a0000000-0000-0000-0000-000000000007',
 'b0000000-0000-0000-0000-000000000001',
 'Paladar La Pinareña',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Restaurante / Paladar'),
 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=300&fit=crop&auto=format',
 'Calle Viñales 5, Reparto Hermanos Cruz', ST_SetSRID(ST_MakePoint(-83.6920,22.4080),4326)::geography,
 'Pinar del Río', '+5348111007', '+5358111007',
 true, true, 4.8),

-- 8 · Carnicería Don Pepe
('a0000000-0000-0000-0000-000000000008',
 'b0000000-0000-0000-0000-000000000001',
 'Carnicería Don Pepe',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Carnicería'),
 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1551028150-64b9f398f678?w=800&h=300&fit=crop&auto=format',
 'Ave. Alameda 67', ST_SetSRID(ST_MakePoint(-83.6895,22.4170),4326)::geography,
 'Pinar del Río', '+5348111008', NULL,
 true, false, 4.4),

-- 9 · Agromercado El Valle
('a0000000-0000-0000-0000-000000000009',
 'b0000000-0000-0000-0000-000000000001',
 'Agromercado El Valle',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Agro / Frutas'),
 'https://images.unsplash.com/photo-1471194402529-8e0f5a675de6?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=300&fit=crop&auto=format',
 'Carretera Central km 3, El Valle', ST_SetSRID(ST_MakePoint(-83.6930,22.4245),4326)::geography,
 'Pinar del Río', '+5348111009', '+5358111009',
 true, true, 4.6),

-- 10 · Cafetería La Terraza
('a0000000-0000-0000-0000-000000000010',
 'b0000000-0000-0000-0000-000000000001',
 'Cafetería La Terraza',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Cafetería'),
 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800&h=300&fit=crop&auto=format',
 'Calle Maceo 101', ST_SetSRID(ST_MakePoint(-83.7050,22.4155),4326)::geography,
 'Pinar del Río', '+5348111010', '+5358111010',
 true, false, 4.5),

-- 11 · Farmacia San Juan
('a0000000-0000-0000-0000-000000000011',
 'b0000000-0000-0000-0000-000000000001',
 'Farmacia San Juan',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Farmacia'),
 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800&h=300&fit=crop&auto=format',
 'Reparto San Juan, Calle 5ta 22', ST_SetSRID(ST_MakePoint(-83.6880,22.4060),4326)::geography,
 'Pinar del Río', '+5348111011', NULL,
 false, true, 4.9),

-- 12 · Panadería El Trigo
('a0000000-0000-0000-0000-000000000012',
 'b0000000-0000-0000-0000-000000000001',
 'Panadería El Trigo',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Panadería'),
 'https://images.unsplash.com/photo-1568254183919-78a4f43a2877?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800&h=300&fit=crop&auto=format',
 'Calle Cuba 34', ST_SetSRID(ST_MakePoint(-83.6860,22.4200),4326)::geography,
 'Pinar del Río', '+5348111012', '+5358111012',
 true, false, 4.3),

-- 13 · Tienda El Palmar
('a0000000-0000-0000-0000-000000000013',
 'b0000000-0000-0000-0000-000000000001',
 'Tienda El Palmar',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Bodega'),
 'https://images.unsplash.com/photo-1553073520-80b5ad5e2b4a?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=300&fit=crop&auto=format',
 'Ave. Rafael Ferro, El Palmar', ST_SetSRID(ST_MakePoint(-83.6800,22.4250),4326)::geography,
 'Pinar del Río', '+5348111013', NULL,
 true, false, 4.1),

-- 14 · Ferretería Los Pinos
('a0000000-0000-0000-0000-000000000014',
 'b0000000-0000-0000-0000-000000000001',
 'Ferretería Los Pinos',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Ferretería'),
 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&h=300&fit=crop&auto=format',
 'Reparto Los Pinos, Bloque B', ST_SetSRID(ST_MakePoint(-83.7090,22.4090),4326)::geography,
 'Pinar del Río', '+5348111014', '+5358111014',
 false, false, 4.2),

-- 15 · Boutique La Moda
('a0000000-0000-0000-0000-000000000015',
 'b0000000-0000-0000-0000-000000000001',
 'Boutique La Moda',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Tienda de ropa'),
 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=800&h=300&fit=crop&auto=format',
 'Calle Colón 8, Centro', ST_SetSRID(ST_MakePoint(-83.7030,22.4140),4326)::geography,
 'Pinar del Río', '+5348111015', '+5358111015',
 true, false, 4.0),

-- 16 · Paladar El Criollo
('a0000000-0000-0000-0000-000000000016',
 'b0000000-0000-0000-0000-000000000001',
 'Paladar El Criollo',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Restaurante / Paladar'),
 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&h=300&fit=crop&auto=format',
 'Reparto Ceferino Fernández', ST_SetSRID(ST_MakePoint(-83.6990,22.4280),4326)::geography,
 'Pinar del Río', '+5348111016', '+5358111016',
 true, true, 4.7),

-- 17 · Cafetería Vista Verde
('a0000000-0000-0000-0000-000000000017',
 'b0000000-0000-0000-0000-000000000001',
 'Cafetería Vista Verde',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Cafetería'),
 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&h=300&fit=crop&auto=format',
 'Parque de la Ciudad, Local 2', ST_SetSRID(ST_MakePoint(-83.6945,22.4165),4326)::geography,
 'Pinar del Río', '+5348111017', '+5358111017',
 true, true, 4.8),

-- 18 · Finca El Paraíso
('a0000000-0000-0000-0000-000000000018',
 'b0000000-0000-0000-0000-000000000001',
 'Finca El Paraíso',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Agro / Frutas'),
 'https://images.unsplash.com/photo-1500651230702-0e2d8a49d4ad?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1471194402529-8e0f5a675de6?w=800&h=300&fit=crop&auto=format',
 'Km 4.5 Carretera a Viñales', ST_SetSRID(ST_MakePoint(-83.6860,22.4310),4326)::geography,
 'Pinar del Río', '+5348111018', '+5358111018',
 true, false, 4.4),

-- 19 · Bodega Los Pinos
('a0000000-0000-0000-0000-000000000019',
 'b0000000-0000-0000-0000-000000000001',
 'Bodega Los Pinos',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Bodega'),
 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1553073520-80b5ad5e2b4a?w=800&h=300&fit=crop&auto=format',
 'Reparto Los Pinos, Calle 3ra', ST_SetSRID(ST_MakePoint(-83.7020,22.4050),4326)::geography,
 'Pinar del Río', '+5348111019', NULL,
 true, false, 4.2),

-- 20 · Electrónica Digital
('a0000000-0000-0000-0000-000000000020',
 'b0000000-0000-0000-0000-000000000001',
 'Electrónica Digital',
 (SELECT id FROM public.categorias_negocio WHERE nombre = 'Electrónica'),
 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400&h=200&fit=crop&auto=format',
 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800&h=300&fit=crop&auto=format',
 'Calle Antonio Rubio 15', ST_SetSRID(ST_MakePoint(-83.7070,22.4175),4326)::geography,
 'Pinar del Río', '+5348111020', '+5358111020',
 true, true, 4.5)

ON CONFLICT (id) DO NOTHING;

-- ── 5. Productos ──────────────────────────────────────────────

INSERT INTO public.productos (negocio_id, nombre, precio, unidad, imagen_url, disponible, stock) VALUES

-- La Panadería Elena (001)
('a0000000-0000-0000-0000-000000000001','Pan Criollo',25,'unidad',
 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000001','Pan Suave',15,'unidad',
 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000001','Bizcocho de Guayaba',120,'unidad',
 'https://images.unsplash.com/photo-1550617931-e17a7b70dce2?w=300&h=300&fit=crop&auto=format',true,'medio'),

-- Agro San Cristóbal (002)
('a0000000-0000-0000-0000-000000000002','Huevos',350,'cajita',
 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000002','Pollo',890,'libra',
 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000002','Tomate',90,'libra',
 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Farmacia Vida (003)
('a0000000-0000-0000-0000-000000000003','Aspirina 500mg',45,'tableta',
 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000003','Omeprazol 20mg',80,'cápsula',
 'https://images.unsplash.com/photo-1628771065518-0d82f1938462?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000003','Amoxicilina 500mg',120,'cápsula',
 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=300&h=300&fit=crop&auto=format',true,'bajo'),

-- Cafetería El Patio (004)
('a0000000-0000-0000-0000-000000000004','Café Americano',80,'taza',
 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000004','Sandwich Mixto',250,'unidad',
 'https://images.unsplash.com/photo-1528736235302-52922df5c122?w=300&h=300&fit=crop&auto=format',true,'medio'),

-- Bodega La Confianza (005)
('a0000000-0000-0000-0000-000000000005','Arroz',180,'libra',
 'https://images.unsplash.com/photo-1536304993881-ff86e0c9ef1d?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000005','Aceite Vegetal',620,'botella',
 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000005','Azúcar Refino',150,'libra',
 'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Paladar La Pinareña (007)
('a0000000-0000-0000-0000-000000000007','Ropa Vieja',800,'porción',
 'https://images.unsplash.com/photo-1565299715199-866c917206bb?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000007','Cerdo Asado',950,'porción',
 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000007','Arroz con Pollo',750,'porción',
 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Carnicería Don Pepe (008)
('a0000000-0000-0000-0000-000000000008','Carne de Res',750,'libra',
 'https://images.unsplash.com/photo-1551028150-64b9f398f678?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000008','Cerdo',680,'libra',
 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300&h=300&fit=crop&auto=format',true,'medio'),

-- Agromercado El Valle (009)
('a0000000-0000-0000-0000-000000000009','Frijoles Negros',200,'libra',
 'https://images.unsplash.com/photo-1589927986089-35812388d1f4?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000009','Yuca',60,'libra',
 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000009','Plátano Macho',45,'unidad',
 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Cafetería La Terraza (010)
('a0000000-0000-0000-0000-000000000010','Café con Leche',120,'taza',
 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000010','Refresco Natural',150,'vaso',
 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Panadería El Trigo (012)
('a0000000-0000-0000-0000-000000000012','Pan de Molde',85,'paquete',
 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000012','Galletas de Vainilla',65,'paquete',
 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Cafetería Vista Verde (017)
('a0000000-0000-0000-0000-000000000017','Café Espresso',60,'taza',
 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000017','Jugo de Guayaba',100,'vaso',
 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=300&h=300&fit=crop&auto=format',true,'medio'),

-- Finca El Paraíso (018)
('a0000000-0000-0000-0000-000000000018','Mango',35,'unidad',
 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=300&h=300&fit=crop&auto=format',true,'alto'),
('a0000000-0000-0000-0000-000000000018','Guayaba',25,'libra',
 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=300&h=300&fit=crop&auto=format',true,'alto'),

-- Electrónica Digital (020)
('a0000000-0000-0000-0000-000000000020','Cargador USB-C',1500,'unidad',
 'https://images.unsplash.com/photo-1618410320928-25228d811631?w=300&h=300&fit=crop&auto=format',true,'medio'),
('a0000000-0000-0000-0000-000000000020','Audífonos Inalámbricos',2500,'unidad',
 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=300&fit=crop&auto=format',true,'bajo');

-- ── 6. Promociones ────────────────────────────────────────────

INSERT INTO public.promociones (negocio_id, titulo, descripcion, imagen_url, fecha_inicio, fecha_fin, activa) VALUES

('a0000000-0000-0000-0000-000000000001',
 'Descuentos de Temporada',
 'Pan criollo y bizcochos con 20% de descuento esta semana',
 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&h=250&fit=crop&auto=format',
 CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', true),

('a0000000-0000-0000-0000-000000000009',
 'Productos Frescos del Día',
 'Cosecha directa del campo: yuca, plátano y vegetales frescos',
 'https://images.unsplash.com/photo-1471194402529-8e0f5a675de6?w=600&h=250&fit=crop&auto=format',
 CURRENT_DATE, CURRENT_DATE + INTERVAL '7 days', true),

('a0000000-0000-0000-0000-000000000003',
 'Medicamentos Disponibles',
 'Aspirina, Omeprazol y antibióticos en stock',
 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=600&h=250&fit=crop&auto=format',
 CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days', true);
