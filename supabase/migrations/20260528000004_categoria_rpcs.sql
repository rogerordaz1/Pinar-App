-- ================================================================
-- RPC para productos filtrados por categoría de negocio
-- Depende de: 20260528000001 (calificacion_cache)
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_productos_por_categoria(
  p_categoria_id  text,
  lat             double precision DEFAULT 22.4164,
  lng             double precision DEFAULT -83.6964
)
RETURNS TABLE (
  negocio_id           text,
  negocio_nombre       text,
  negocio_direccion    text,
  negocio_abierto      boolean,
  negocio_verificado   boolean,
  logo_url             text,
  producto_id          text,
  producto_nombre      text,
  precio               double precision,
  disponible           boolean,
  ultima_actualizacion text,
  distancia_metros     double precision,
  calificacion         double precision
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    n.id::text                                                           AS negocio_id,
    n.nombre                                                             AS negocio_nombre,
    n.direccion                                                          AS negocio_direccion,
    n.abierto                                                            AS negocio_abierto,
    n.verificado                                                         AS negocio_verificado,
    n.logo_url,
    p.id::text                                                           AS producto_id,
    p.nombre                                                             AS producto_nombre,
    p.precio::double precision                                           AS precio,
    p.disponible,
    p.ultima_actualizacion::text,
    ST_Distance(
      n.ubicacion::geography,
      ST_MakePoint(lng, lat)::geography
    )                                                                    AS distancia_metros,
    COALESCE(
      AVG(r.calificacion)::double precision,
      n.calificacion_cache::double precision,
      0.0
    )                                                                    AS calificacion
  FROM public.productos p
  JOIN public.negocios n ON p.negocio_id = n.id
  LEFT JOIN public.resenas r ON r.negocio_id = n.id
  WHERE n.categoria_id::text = p_categoria_id
    AND p.disponible = true
    AND n.activo = true
  GROUP BY n.id, p.id
  ORDER BY distancia_metros ASC
  LIMIT 50;
$$;

GRANT EXECUTE ON FUNCTION public.get_productos_por_categoria(text, double precision, double precision)
  TO authenticated, anon;
