-- ================================================================
-- RPCs para búsqueda de productos con filtros y ordenamiento
-- Depende de: 20260528000001 (columnas unidad y calificacion_cache)
-- ================================================================

CREATE OR REPLACE FUNCTION public.buscar_productos(
  termino       text,
  lat           double precision DEFAULT 22.4164,
  lng           double precision DEFAULT -83.6964,
  radio_metros  double precision DEFAULT 50000,
  solo_abierto  boolean          DEFAULT false,
  orden         text             DEFAULT 'distancia'
)
RETURNS TABLE (
  negocio_id          text,
  negocio_nombre      text,
  negocio_direccion   text,
  negocio_abierto     boolean,
  negocio_verificado  boolean,
  logo_url            text,
  producto_id         text,
  producto_nombre     text,
  precio              double precision,
  disponible          boolean,
  ultima_actualizacion text,
  distancia_metros    double precision,
  calificacion        double precision
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  WITH base AS (
    SELECT
      n.id::text                                                          AS negocio_id,
      n.nombre                                                            AS negocio_nombre,
      n.direccion                                                         AS negocio_direccion,
      n.abierto                                                           AS negocio_abierto,
      n.verificado                                                        AS negocio_verificado,
      n.logo_url,
      p.id::text                                                          AS producto_id,
      p.nombre                                                            AS producto_nombre,
      p.precio::double precision                                          AS precio,
      p.disponible,
      p.ultima_actualizacion::text,
      ST_Distance(
        n.ubicacion::geography,
        ST_MakePoint(lng, lat)::geography
      )                                                                   AS distancia_metros,
      COALESCE(
        AVG(r.calificacion)::double precision,
        n.calificacion_cache::double precision,
        0.0
      )                                                                   AS calificacion
    FROM public.productos p
    JOIN public.negocios n ON p.negocio_id = n.id
    LEFT JOIN public.resenas r ON r.negocio_id = n.id
    WHERE
      p.nombre ILIKE '%' || termino || '%'
      AND p.disponible = true
      AND n.activo = true
      AND ST_DWithin(
        n.ubicacion::geography,
        ST_MakePoint(lng, lat)::geography,
        radio_metros
      )
      AND (NOT solo_abierto OR n.abierto = true)
    GROUP BY n.id, p.id
  )
  SELECT *
  FROM base
  ORDER BY
    (CASE WHEN orden = 'precio'       THEN precio            ELSE NULL END) ASC  NULLS LAST,
    (CASE WHEN orden = 'calificacion' THEN calificacion      ELSE NULL END) DESC NULLS LAST,
    (CASE WHEN orden NOT IN ('precio','calificacion') THEN distancia_metros ELSE NULL END) ASC NULLS LAST
  LIMIT 30;
$$;

CREATE OR REPLACE FUNCTION public.get_negocios_recomendados(
  lat double precision DEFAULT 22.4164,
  lng double precision DEFAULT -83.6964
)
RETURNS TABLE (
  id           text,
  nombre       text,
  descripcion  text,
  logo_url     text,
  calificacion double precision,
  distancia_km double precision
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    n.id::text,
    n.nombre,
    n.descripcion,
    n.logo_url,
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
  LEFT JOIN public.resenas r ON r.negocio_id = n.id
  WHERE n.activo = true AND n.verificado = true
  GROUP BY n.id
  ORDER BY ST_Distance(
    n.ubicacion::geography,
    ST_MakePoint(lng, lat)::geography
  ) ASC
  LIMIT 5;
$$;

GRANT EXECUTE ON FUNCTION public.buscar_productos(text, double precision, double precision, double precision, boolean, text) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_negocios_recomendados(double precision, double precision) TO authenticated, anon;
