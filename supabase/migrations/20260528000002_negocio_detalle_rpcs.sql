-- ================================================================
-- RPCs para la página de detalle de negocio
-- Ejecutar en Supabase SQL Editor (service role)
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_negocio_detalle(
  p_id  text,
  lat   double precision DEFAULT 22.4164,
  lng   double precision DEFAULT -83.6964
)
RETURNS TABLE (
  id             text,
  nombre         text,
  categoria      text,
  abierto        boolean,
  verificado     boolean,
  calificacion   double precision,
  total_resenas  int,
  direccion      text,
  telefono       text,
  whatsapp       text,
  logo_url       text,
  hero_image_url text,
  distancia_km   double precision
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    n.id::text,
    n.nombre,
    COALESCE(c.nombre, 'Otro'),
    n.abierto,
    n.verificado,
    COALESCE(
      AVG(r.calificacion)::double precision,
      n.calificacion_cache::double precision,
      0.0
    ),
    COUNT(r.id)::int,
    n.direccion,
    n.telefono,
    n.whatsapp,
    n.logo_url,
    n.banner_url,
    (ST_Distance(
      n.ubicacion::geography,
      ST_MakePoint(lng, lat)::geography
    ) / 1000.0)::double precision
  FROM public.negocios n
  LEFT JOIN public.categorias_negocio c ON n.categoria_id = c.id
  LEFT JOIN public.resenas r ON r.negocio_id = n.id
  WHERE n.id = p_id::uuid AND n.activo = true
  GROUP BY n.id, c.nombre
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.get_productos_negocio(p_negocio_id text)
RETURNS TABLE (
  id                   text,
  nombre               text,
  precio               double precision,
  unidad               text,
  disponible           boolean,
  imagen_url           text,
  ultima_actualizacion text
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.id::text,
    p.nombre,
    p.precio::double precision,
    p.unidad,
    p.disponible,
    p.imagen_url,
    p.ultima_actualizacion::text
  FROM public.productos p
  WHERE p.negocio_id = p_negocio_id::uuid
  ORDER BY p.disponible DESC, p.nombre ASC;
$$;

GRANT EXECUTE ON FUNCTION public.get_negocio_detalle(text, double precision, double precision) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_productos_negocio(text) TO authenticated, anon;
