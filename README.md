# +Sustentable — Landing (massustentable.cl)

Sitio estático (HTML/CSS/JS vainilla, sin build) de la página principal de **+Sustentable**, optimizado para desplegarse en **Cloudflare Pages**.
La plataforma web vive en un proyecto y subdominio aparte: **https://app.massustentable.cl**.

```
massustentable.cl        → Cloudflare Pages (este repositorio: landing estática)
app.massustentable.cl    → Azure (repositorio de la app: React + backend)
```

---

## Estructura del Proyecto

```text
public/                       ← Directorio raíz de publicación en Cloudflare Pages
├── index.html                Landing page principal
├── 404.html                  Fallback: reenvía rutas desconocidas a app.massustentable.cl (conserva ruta, query y hash)
├── _redirects                Redirecciones 301 directas en el Edge de Cloudflare (rutas antiguas de la app)
├── _headers                  Cabeceras HTTP de seguridad (X-Content-Type-Options, Referrer-Policy) y caché
├── css/styles.css            Estilos completos con paleta y tipografías centralizadas en :root
├── js/main.js                Slider interactivo + scroll suave del logo (vanilla JS, sin librerías)
├── img/                      Logotipos extraídos en PNG optimizado (logo, isotipo, Corfo, Social Renovable)
├── robots.txt                Control de indexación para buscadores
└── sitemap.xml               Mapa de sitio para Google Search Console
scripts/
└── test.sh                   Suite de pruebas automatizadas (33 validaciones de rutas, assets y redirecciones)
```

---

## Ver y Probar en Local

1. **Opción rápida:** Puedes abrir `public/index.html` con doble clic en tu navegador (todas las rutas relativas funcionan).
2. **Con el emulador oficial de Cloudflare Pages (Wrangler):**
   Permite comprobar las redirecciones 301 de `_redirects` y las cabeceras de `_headers` de forma idéntica a producción:
   ```bash
   npx wrangler pages dev public --port 8788
   ```
   Y en otra terminal puedes ejecutar el script de pruebas automatizado:
   ```bash
   ./scripts/test.sh http://localhost:8788
   ```

---

## Despliegue en Cloudflare Pages (Paso a Paso)

### 1. Subir a tu GitHub
1. Crea un repositorio en tu perfil de GitHub (por ejemplo `massustentable-landing`).
2. Sube el contenido de esta carpeta:
   ```bash
   git remote add origin https://github.com/TU_USUARIO/massustentable-landing.git
   git push -u origin main
   ```

### 2. Conectar a Cloudflare Pages
1. Inicia sesión en Cloudflare con la cuenta a la que te invitaron.
2. Ve a **Workers & Pages** → **Create application** → pestaña **Pages** → **Connect to Git**.
3. Selecciona tu repositorio de GitHub `massustentable-landing`.
4. En la configuración del build:
   - **Framework preset:** `None`
   - **Build command:** *(dejar vacío)*
   - **Build output directory:** `public`
   - **Root directory:** *(dejar vacío o `/`)*
5. Haz clic en **Save and Deploy**. En menos de 30 segundos tu landing tendrá una URL pública temporal tipo `https://massustentable-landing.pages.dev`.

### 3. Asociar el Dominio Personalizado
En el proyecto de Pages en Cloudflare:
1. Ve a la pestaña **Custom domains** → **Set up a custom domain**.
2. Ingresa `massustentable.cl` (y opcionalmente `www.massustentable.cl`).
3. Como la zona DNS de `massustentable.cl` ya está en la misma cuenta de Cloudflare, la activación es instantánea y automática (Cloudflare gestiona el SSL y el DNS por ti).

---

## Migración de Dominio (Sin Tiempo de Caída)

Para que el paso de la app hacia el subdominio `app.massustentable.cl` sea 100% fluido:

| # | Responsable | Paso |
|---|---|---|
| 1 | **Equipo App** | En su Azure Static Web App, agregar el dominio personalizado `app.massustentable.cl` (en Cloudflare DNS: crear registro `CNAME app` apuntando al host de Azure). |
| 2 | **Equipo App** | En `backend/main.py` (`CORSMiddleware.allow_origins`), agregar `"https://app.massustentable.cl"` para que la API permita peticiones desde el subdominio. |
| 3 | **Equipo App** | En Google Cloud Console (OAuth 2.0), agregar `https://app.massustentable.cl` a los **Orígenes de JavaScript autorizados** para que el login con Google funcione. |
| 4 | **Equipo App** | Actualizar la variable de entorno del backend `FRONTEND_URL=https://app.massustentable.cl` (enlaces de correos). |
| 5 | **Todos** | Probar la app en `app.massustentable.cl` (login, dashboard, autodiagnóstico). Durante esta prueba, `massustentable.cl` sigue atendiendo con normalidad. |
| 6 | **Landing** | Desplegar este repositorio en Cloudflare Pages y verificar con `./scripts/test.sh https://<proyecto>.pages.dev`. |
| 7 | **Landing / DNS** | En Cloudflare Pages, vincular el dominio `massustentable.cl`. A partir de este momento, la landing atiende la raíz y las rutas antiguas redirigen automáticamente con 301 a `app.massustentable.cl`. |
| 8 | **Landing** | Ejecutar `./scripts/test.sh https://massustentable.cl` para confirmar que todo responde en producción. |

> **Nota para usuarios:** Al migrar a `app.massustentable.cl`, el `localStorage` del navegador es independiente para cada subdominio. Los usuarios existentes deberán iniciar sesión una vez más en `app.massustentable.cl`. Sus cuentas y datos no se ven afectados.

---

## SEO y Google Search Console (GSC)

- **Propiedad recomendada:** Crear en Google Search Console una propiedad de tipo **Dominio** (`massustentable.cl`). Esto cubre automáticamente tanto la landing como el subdominio `app.massustentable.cl`.
- **Verificación:** Se verifica mediante un registro DNS de tipo `TXT` en Cloudflare. Como la cuenta de Cloudflare ya gestiona el dominio, se añade en segundos.
- **Titularidad:** Se recomienda que la cuenta propietaria en Google Search Console sea una cuenta institucional del proyecto (ej. de Social Renovable) y que te agreguen como usuario con permisos completos.
- **Sitemap:** Una vez verificada la propiedad en GSC, enviar `https://massustentable.cl/sitemap.xml`.

---

## Pendientes de Contenido

- Enlace del video de "Cómo funciona" (botón *"Ver video"* en el slider).
- Destino definitivo de *"Conversemos"* (actualmente abre correo a `mailto:contacto@socialrenovable.cl`).
- Enlaces definitivos de *Política de privacidad* y *Términos y condiciones*.
- Imagen de 1200×630 px para la metaetiqueta `og:image` (tarjeta al compartir en WhatsApp / LinkedIn).
