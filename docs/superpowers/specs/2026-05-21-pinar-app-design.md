# Pinar App — Diseño del Sistema
**Fecha:** 2026-05-21
**Estado:** Aprobado
**Equipo:** 2 desarrolladores

---

## 1. Visión del Producto

Pinar App resuelve un problema real del cubano: encontrar productos disponibles en negocios cercanos en tiempo real.

Un usuario busca "huevos" y la app le muestra qué negocios los tienen disponibles, dónde están y qué tan lejos quedan.

La app es una mezcla entre:
- Directorio de negocios local
- Buscador de productos en tiempo real
- Sistema comunitario de verificación
- Marketplace de visibilidad para negocios

**Mercado inicial:** Pinar del Río, Cuba
**Escalabilidad:** Nacional (todas las provincias de Cuba)

---

## 2. Público Objetivo

**Clientes (consumidores):**
- Personas en Cuba con internet móvil limitado y lento
- Usuarios poco técnicos
- Cualquier persona que busque productos o servicios en su zona

**Negocios:**
- Cuentapropistas (paladares, tiendas particulares, agros, farmacias privadas)
- Negocios pequeños y medianos
- Target de pago: dueños de negocios con capacidad de suscripción

---

## 3. Stack Tecnológico

| Capa | Tecnología | Justificación |
|---|---|---|
| Mobile | Flutter (Android first, iOS después) | Experiencia previa del equipo |
| State Management | BLoC + Cubit | Elegido por el equipo |
| Data Classes | Freezed | Inmutabilidad y sealed classes |
| Igualdad | Equatable | Comparación de estados en BLoC |
| Inyección de dependencias | get_it | DI simple y eficiente |
| Backend | Supabase | PostgreSQL + Auth + Storage + Realtime, no-Google, accesible desde Cuba |
| Base de datos | PostgreSQL + PostGIS | Queries geoespaciales nativas |
| Mapas | OpenStreetMap + flutter_map | Sin Google, mejor cobertura en Cuba, sin costo por API |
| Push Notifications | Sin push en MVP, FCM en v1.1 | Simplifica el MVP, FCM funciona en la mayoría de Android cubanos con GMS |
| Arquitectura | Clean Architecture (3 capas) | Backend intercambiable sin afectar la app |

**Decisiones NO-Google por diseño:**
- Sin Firebase (requiere VPN en Cuba)
- Sin Google Maps (cobertura limitada en Cuba, costo por API)
- Supabase corre sobre AWS, accesible desde Cuba sin VPN

---

## 4. Arquitectura — Clean Architecture

La app nunca habla directamente con Supabase. El SDK de Supabase vive únicamente en la capa Data. Si el backend cambia mañana, solo se reemplaza la implementación del repositorio.

```
Presentation Layer
    BLoC / Cubit
    Widgets / Pages
         │
         ▼
Domain Layer
    Entities (objetos puros de negocio)
    Repository interfaces (abstractas)
    Use Cases (un caso de uso por clase)
         │
         ▼
Data Layer
    Repository implementations
    Data Sources (Supabase SDK aquí)
    Models (extienden entities, manejan JSON)
```

**get_it como puente:**
```dart
// Cambiar backend = cambiar esta línea solamente
sl.registerLazySingleton<NegocioRepository>(
  () => SupabaseNegocioRepository(sl())
);
```

---

## 5. Estructura de Carpetas Flutter

```
lib/
├── core/
│   ├── constants/          # strings, keys, config
│   ├── errors/             # failures, exceptions
│   ├── theme/              # colores, tipografía, estilos
│   ├── usecases/           # UseCase base abstracto
│   ├── utils/              # helpers, extensiones
│   └── widgets/            # widgets reutilizables globales
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/     # SupabaseAuthDataSource
│   │   │   ├── models/          # UserModel (Freezed)
│   │   │   └── repositories/    # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/        # User (Freezed)
│   │   │   ├── repositories/    # AuthRepository (abstract)
│   │   │   └── usecases/        # LoginUseCase, RegisterUseCase
│   │   └── presentation/
│   │       ├── bloc/            # AuthBloc, AuthEvent, AuthState
│   │       ├── pages/           # LoginPage, RegisterPage
│   │       └── widgets/
│   │
│   ├── busqueda/           # búsqueda de productos
│   ├── negocios/           # listado y perfil de negocios
│   ├── productos/          # catálogo por negocio
│   ├── mapa/               # mapa interactivo (v1.1)
│   ├── comunidad/          # verificación comunitaria (v1.1)
│   ├── suscripcion/        # planes y pagos del negocio
│   ├── perfil_cliente/     # favoritos, historial, config
│   └── admin/              # panel de moderación (v1.1)
│
├── injection_container.dart    # registro de get_it
├── app.dart                    # MaterialApp + router
└── main.dart
```

**Regla:** Cada feature sigue exactamente la misma estructura interna (data / domain / presentation). Sin excepciones.

---

## 6. Modelo de Datos (PostgreSQL)

### Tablas principales

**`users`**
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
email           TEXT UNIQUE NOT NULL
telefono        TEXT
nombre          TEXT
avatar_url      TEXT
es_negocio      BOOLEAN DEFAULT false
created_at      TIMESTAMPTZ DEFAULT now()
```

**`categorias_negocio`**
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
nombre          TEXT NOT NULL    -- "Cafetería", "Agro", "Farmacia"
icono           TEXT
color           TEXT             -- hex para pin del mapa
```

**`negocios`**
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
owner_id        UUID NOT NULL REFERENCES users(id)
nombre          TEXT NOT NULL
descripcion     TEXT
categoria_id    UUID REFERENCES categorias_negocio(id)
logo_url        TEXT
banner_url      TEXT
direccion       TEXT NOT NULL
ubicacion       GEOGRAPHY(POINT, 4326) NOT NULL  -- PostGIS
telefono        TEXT
whatsapp        TEXT
instagram       TEXT
facebook        TEXT
abierto         BOOLEAN DEFAULT true
verificado      BOOLEAN DEFAULT false
activo          BOOLEAN DEFAULT true
created_at      TIMESTAMPTZ DEFAULT now()
updated_at      TIMESTAMPTZ DEFAULT now()
```

**`categorias_producto`**
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
nombre          TEXT NOT NULL    -- "Huevos", "Aceite", "Lácteos"
icono           TEXT
```

**`productos`**
```sql
id                   UUID PRIMARY KEY DEFAULT gen_random_uuid()
negocio_id           UUID NOT NULL REFERENCES negocios(id)
nombre               TEXT NOT NULL
descripcion          TEXT
precio               DECIMAL(10,2)
moneda               TEXT DEFAULT 'cup'   -- cup | usd | mlc
imagen_url           TEXT
disponible           BOOLEAN DEFAULT true
stock                TEXT                 -- 'alto' | 'medio' | 'bajo' | 'agotado'
ultima_actualizacion TIMESTAMPTZ DEFAULT now()
created_at           TIMESTAMPTZ DEFAULT now()
```

**`producto_categorias`** (muchos a muchos)
```sql
producto_id     UUID REFERENCES productos(id)
categoria_id    UUID REFERENCES categorias_producto(id)
PRIMARY KEY (producto_id, categoria_id)
```

**`planes_suscripcion`**
```sql
id                      UUID PRIMARY KEY DEFAULT gen_random_uuid()
nombre                  TEXT NOT NULL       -- 'basico' | 'premium' | 'vip'
precio_usd_mensual      DECIMAL(6,2)        -- definir tras estudio de mercado
precio_cup_mensual      DECIMAL(10,2)       -- definir tras estudio de mercado
max_productos           INTEGER             -- NULL = ilimitado
destacado_busqueda      BOOLEAN DEFAULT false
analytics               BOOLEAN DEFAULT false
badge_verificado        BOOLEAN DEFAULT false
publicidad_en_app       BOOLEAN DEFAULT false
posicionamiento         INTEGER             -- 1=VIP, 2=Premium, 3=Básico
```

> **Nota:** Los precios de los planes se definirán después del estudio de mercado. La estructura está lista para configurarse sin cambiar código.

**`suscripciones`**
```sql
id                  UUID PRIMARY KEY DEFAULT gen_random_uuid()
negocio_id          UUID NOT NULL REFERENCES negocios(id)
plan_id             UUID NOT NULL REFERENCES planes_suscripcion(id)
estado              TEXT NOT NULL   -- 'activa' | 'vencida' | 'cancelada' | 'pendiente'
fecha_inicio        DATE NOT NULL
fecha_vencimiento   DATE NOT NULL
metodo_pago         TEXT            -- 'stripe' | 'paypal' | 'transfermovil' | 'enzona' | 'manual'
monto_pagado        DECIMAL(8,2)
moneda              TEXT            -- 'usd' | 'cup'
referencia_pago     TEXT            -- ID externo de Stripe, etc.
created_at          TIMESTAMPTZ DEFAULT now()
```

**`verificaciones`** (sistema comunitario — v1.1)
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
producto_id     UUID NOT NULL REFERENCES productos(id)
usuario_id      UUID NOT NULL REFERENCES users(id)
tipo            TEXT NOT NULL   -- 'confirmado' | 'reportado'
comentario      TEXT
created_at      TIMESTAMPTZ DEFAULT now()
```

**`favoritos`**
```sql
usuario_id      UUID REFERENCES users(id)
negocio_id      UUID REFERENCES negocios(id)
created_at      TIMESTAMPTZ DEFAULT now()
PRIMARY KEY (usuario_id, negocio_id)
```

**`resenas`**
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
negocio_id      UUID NOT NULL REFERENCES negocios(id)
usuario_id      UUID NOT NULL REFERENCES users(id)
calificacion    SMALLINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5)
comentario      TEXT
created_at      TIMESTAMPTZ DEFAULT now()
UNIQUE (negocio_id, usuario_id)
```

**`horarios`**
```sql
negocio_id      UUID REFERENCES negocios(id)
dia_semana      SMALLINT NOT NULL   -- 0=lunes ... 6=domingo
hora_apertura   TIME
hora_cierre     TIME
cerrado         BOOLEAN DEFAULT false
PRIMARY KEY (negocio_id, dia_semana)
```

**`promociones`** (plan Premium/VIP — v1.1)
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
negocio_id      UUID NOT NULL REFERENCES negocios(id)
titulo          TEXT NOT NULL
descripcion     TEXT
imagen_url      TEXT
fecha_inicio    DATE NOT NULL
fecha_fin       DATE NOT NULL
activa          BOOLEAN DEFAULT true
```

### Query central del sistema

Búsqueda de productos con geolocalización:

```sql
SELECT
  n.id, n.nombre, n.direccion, n.abierto, n.verificado,
  p.nombre AS producto, p.precio, p.moneda, p.disponible, p.stock,
  p.ultima_actualizacion,
  ST_Distance(n.ubicacion, ST_MakePoint($lng, $lat)::geography) AS distancia_metros,
  COALESCE(AVG(r.calificacion), 0) AS calificacion
FROM productos p
JOIN negocios n ON p.negocio_id = n.id
LEFT JOIN resenas r ON r.negocio_id = n.id
WHERE
  p.nombre ILIKE '%' || $termino || '%'
  AND p.disponible = true
  AND n.activo = true
  AND ST_DWithin(n.ubicacion, ST_MakePoint($lng, $lat)::geography, $radio_metros)
GROUP BY n.id, p.id
ORDER BY distancia_metros ASC;
```

---

## 7. Navegación y Flujo de Pantallas

### Estructura de navegación

```
App
├── Mundo Cliente (BottomNavigationBar — 4 tabs)
│   ├── Inicio
│   ├── Buscar
│   ├── Favoritos
│   └── Perfil ──► [si es_negocio=true] → Mundo Negocio
│
└── Mundo Negocio (BottomNavigationBar propio)
    ├── Dashboard
    ├── Productos
    ├── Mi Negocio
    └── Suscripción
```

### Pantallas — Auth
- `SplashScreen` → detecta sesión activa
- `OnboardingScreen` → 3 slides (solo primera vez)
- `LoginPage`
- `RegisterPage`

### Pantallas — Mundo Cliente
- `HomeScreen` → negocios cercanos, categorías, promociones
- `CategoriaScreen` → negocios filtrados por categoría
- `BusquedaScreen` → barra de búsqueda + sugerencias
- `ResultadosScreen` → lista de resultados con filtros
- `NegocioDetailScreen` → perfil completo del negocio
- `ProductoDetailScreen` → detalle de producto + verificación comunitaria
- `FavoritosScreen`
- `PerfilClienteScreen`

### Pantallas — Registro de Negocio (flujo de 5 pasos)
1. Información básica (nombre, categoría, descripción, contacto)
2. Ubicación (dirección + pin en mapa)
3. Horarios
4. Elegir plan
5. Método de pago

### Pantallas — Mundo Negocio
- `DashboardScreen` → métricas, estado suscripción, accesos rápidos
- `ProductosScreen` → lista con toggle rápido disponible/agotado
- `AgregarEditarProductoScreen`
- `ActualizarDisponibilidadScreen` → pantalla estrella: todos los productos con toggle, completable en <30 segundos
- `MiNegocioScreen` → editar perfil, horarios, fotos, redes
- `SuscripcionScreen` → plan actual, vencimiento, historial de pagos, renovar

### Pantallas — v1.1
- `MapaScreen` → mapa interactivo con filtros
- `VerificacionComunidadScreen`
- `PromocionesScreen`
- `AnalyticsScreen`

---

## 8. Modelo de Monetización

### Estructura de planes

| Feature | Básico | Premium | VIP |
|---|---|---|---|
| Aparecer en búsquedas | ✅ | ✅ | ✅ |
| Perfil completo | ✅ | ✅ | ✅ |
| Máx. productos | 15 | 100 | Ilimitados |
| Posicionamiento en resultados | Normal | Mejorado | TOP |
| Promociones activas | ❌ | 3 | Ilimitadas |
| Estadísticas básicas | ✅ | ✅ | ✅ |
| Analytics avanzado | ❌ | ✅ | ✅ |
| Badge en perfil | ❌ | `Premium` | `Verificado` |
| Pin destacado en mapa | ❌ | ❌ | ✅ |
| Banner en Home | ❌ | ❌ | ✅ |
| Notificaciones a usuarios cercanos | ❌ | ✅ | ✅ |

> **Precios:** Pendientes de estudio de mercado. La estructura de la base de datos permite configurar precios sin cambios de código.

### Pagos híbridos

**Internacional (incentivado):**
- Stripe (tarjeta débito/crédito) — activación automática
- PayPal — activación automática
- Descuento adicional por pago anual o semestral

**Local Cuba (manual):**
- Transfermóvil / EnZona / Efectivo
- El negocio envía comprobante
- Admin verifica y activa manualmente en panel

### Ciclo de suscripción
1. 14 días de prueba gratis (sin tarjeta)
2. Activa → aviso 30 días antes de vencer
3. Vencida → período de gracia 7 días (perfil visible pero sin renovar)
4. Suspendida → perfil oculto, datos conservados
5. Reactivable en cualquier momento

### Incentivos de lanzamiento
- 14 días gratis al registrar negocio
- Programa de referidos: 1 mes gratis por negocio referido activo
- Descuento de lanzamiento para primeros negocios de Pinar del Río

---

## 9. MVP v1.0 — Alcance

### Incluido en MVP

**Cliente:**
- Registro y login (email + contraseña)
- Home con negocios cercanos por categoría
- Búsqueda de productos con resultados en lista
- Filtros básicos (más cerca, abierto ahora)
- Perfil del negocio (info, productos, horario, contacto)
- Favoritos
- Perfil de usuario

**Negocio:**
- Registro de negocio (flujo de 5 pasos)
- Dashboard básico
- Gestión de productos (CRUD + toggle disponible/agotado)
- Actualización rápida de disponibilidad (<30 segundos)
- Edición de perfil del negocio
- Pantalla de suscripción (info del plan)

**Admin:**
- Panel web via Supabase Dashboard (sin app propia)
- Activar/desactivar negocios manualmente
- Activar suscripciones manualmente (pagos locales)

### Excluido del MVP (v1.1+)
- Mapa interactivo
- Sistema comunitario de verificación
- Push notifications
- Promociones
- Analytics avanzado
- Pagos automáticos (Stripe/PayPal)
- Panel de admin propio
- Reseñas y calificaciones
- iOS

---

## 10. Roadmap de Desarrollo

| Fase | Contenido | Duración |
|---|---|---|
| **Fase 0** | Setup: repo, Supabase, Flutter base, tema, routing, DI | 2 semanas |
| **Fase 1** | MVP Cliente: auth, home, búsqueda, resultados, perfil negocio, favoritos | 4 semanas |
| **Fase 2** | MVP Negocio: registro, dashboard, productos, disponibilidad, suscripción | 4 semanas |
| **Fase 3** | Beta privada: 20-30 negocios reales, corrección de bugs, ajustes UX | 2 semanas |
| **Fase 4** | Lanzamiento Pinar del Río (APK por WhatsApp/grupos) | semana 12 |
| **Fase 5** | v1.1: mapa, comunidad, reseñas, pagos automáticos, push | mes 4-5 |
| **Fase 6** | Expansión nacional: multi-provincia, admin panel, iOS | mes 6+ |

**Tiempo estimado al lanzamiento:** 12 semanas (equipo full-time) / 5-6 meses (parcial)

---

## 11. Estrategia de Escalabilidad Nacional

### Modelo de datos multi-provincia
Agregar `provincia` y `municipio` a la tabla `negocios`. Las búsquedas siempre usan geolocalización (PostGIS), así que escalan naturalmente — no hay lógica por provincia.

### Distribución
- APK distribuido por WhatsApp, Telegram y grupos de Facebook (no Google Play Store en el MVP)
- Google Play Store en v1.1 (requiere cuenta de desarrollador y proceso de revisión)

### Infraestructura
- Supabase Cloud escala automáticamente
- PostGIS maneja millones de puntos geográficos sin cambios de arquitectura
- Las imágenes (logos, banners, productos) en Supabase Storage (CDN incluido)

### Siguiente decisión pendiente
Estudio de mercado para definir precios de suscripción antes de activar cobros reales.

---

## 12. Decisiones Pendientes

| Decisión | Estado | Bloqueada por |
|---|---|---|
| Precios de planes de suscripción | Pendiente | Estudio de mercado |
| Integración Stripe (pagos internacionales) | Pendiente | Estudio de mercado |
| Integración Transfermóvil/EnZona | Pendiente | Estudio de mercado |
| Nombre definitivo de la app | Pendiente | Decisión del equipo |
| Identidad visual (colores, logo) | Pendiente | Diseño UX/UI |
| Política de moderación de contenido | Pendiente | Definir reglas del negocio |
