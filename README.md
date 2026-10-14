# +Sustentable — Landing (massustentable.cl)

Sitio estático (HTML/CSS/JS vainilla, sin build) de la página principal de **+Sustentable**.
La plataforma vive en un proyecto aparte: **https://app.massustentable.cl**.

```
massustentable.cl        → este repositorio (landing)
app.massustentable.cl    → repositorio de la app (React + backend)
```

## Estructura

```
public/                       ← lo único que se publica
├── index.html                landing
├── 404.html                  reenvía rutas desconocidas a app.massustentable.cl (conserva ruta y parámetros)
├── css/styles.css            estilos; paleta y tipografías en :root
├── js/main.js                slider + scroll del logo (sin dependencias)
├── img/                      logos (extraídos del base64 del HTML v20)
├── robots.txt / sitemap.xml  SEO
└── staticwebapp.config.json  redirecciones 301 de rutas antiguas, 404, caché
scripts/test.sh               pruebas automáticas (local, preview o producción)
```

## Ver en local

- Rápido: abrir `public/index.html` con doble clic (las rutas son relativas).
- Igual que en Azure (incluye redirecciones y 404):
  ```bash
  npx @azure/static-web-apps-cli start public --port 4280
  ./scripts/test.sh                 # contra http://localhost:4280
  ```

## Enlaces a la app

Todos los botones "Entrar a la plataforma" apuntan a `https://app.massustentable.cl/login`.
Si cambia el subdominio, buscar y reemplazar `https://app.massustentable.cl` en `public/`.

**Rutas antiguas:** hoy la app está en `massustentable.cl/login`, `/dashboard`, etc. Cuando la landing ocupe el
dominio raíz, esas URLs (marcadores, correos ya enviados) siguen funcionando:
- Rutas de primer nivel (`/login`, `/dashboard`, `/bienvenida`, …) → **301** a la misma ruta en la app.
- Rutas anidadas o con parámetros (`/autodiagnostico/…/seccion/2`, `/reset-password?email=…`) → `404.html`
  reenvía por JS conservando ruta, parámetros y ancla.

## Despliegue (Azure Static Web Apps, plan Free)

1. Crear un recurso **Static Web App** nuevo y conectarlo a este repositorio (GitHub).
2. Detalles de build: *App location* `public`, *Api location* vacío, *Output location* vacío.
   Azure genera el workflow de GitHub Actions; no hay paso de build.
3. Cada push a `main` publica; cada Pull Request crea un entorno de preview con URL propia
   (probar con `./scripts/test.sh https://<preview>.azurestaticapps.net`).

## Migración de dominio (orden recomendado, sin caída)

| # | Quién | Paso |
|---|---|---|
| 1 | Equipo app | Agregar dominio personalizado `app.massustentable.cl` a la Static Web App **de la app** (Cloudflare: `CNAME app → <app>.azurestaticapps.net`, en *DNS only* mientras Azure valida). |
| 2 | Equipo app | Backend `main.py` → `CORSMiddleware.allow_origins`: agregar `"https://app.massustentable.cl"` y redesplegar. Sin esto la app no puede llamar a la API desde el subdominio. |
| 3 | Equipo app | Google Cloud Console → credencial OAuth → **Orígenes de JavaScript autorizados**: agregar `https://app.massustentable.cl` (la app usa Google Identity Services, no requiere redirect URI). |
| 4 | Equipo app | Variable de entorno del backend `FRONTEND_URL=https://app.massustentable.cl` (enlaces en correos). |
| 5 | Todos | Probar la app completa en `app.massustentable.cl`: login con correo, login con Google, registro, recuperar contraseña, dashboard. `massustentable.cl` sigue mostrando la app mientras tanto. |
| 6 | Landing | Desplegar este repo (sección anterior) y revisarlo en su URL `*.azurestaticapps.net`. |
| 7 | Equipo app + Landing | Quitar `massustentable.cl` / `www` de la SWA de la app y agregarlos a la SWA de la landing (Cloudflare: `CNAME @` con *CNAME flattening* y validación por `TXT`; `www` → `CNAME`). |
| 8 | Landing | `./scripts/test.sh https://massustentable.cl` y revisar el clic en "Entrar a la plataforma". |

> **Aviso a usuarios:** la sesión se guarda en `localStorage`, que es por dominio. Al pasar a
> `app.massustentable.cl` cada usuario deberá **iniciar sesión una vez más**. Sus datos no se pierden.

## Pendientes de contenido

- URL del video "Cómo funciona" (botón "Ver video").
- Destino definitivo de "Conversemos" (hoy `mailto:contacto@socialrenovable.cl`).
- URLs de Política de privacidad y Términos y condiciones.
- Imagen 1200×630 para `og:image` (vista previa al compartir en WhatsApp/LinkedIn).
