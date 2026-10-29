#!/usr/bin/env bash
# Pruebas de la landing independiente (massustentable.cl) en Cloudflare Pages.
# Uso: ./scripts/test.sh [base_url]
#      Por defecto: http://localhost:8788 (wrangler pages dev)
#      También sirve contra la URL de Cloudflare Pages:
#      ./scripts/test.sh https://<proyecto>.pages.dev
#      ./scripts/test.sh https://massustentable.cl
BASE="${1:-http://localhost:8788}"
APP="https://app.massustentable.cl"
pass=0; fail=0
ok()   { pass=$((pass+1)); printf '  OK    %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf '  FALLA %s\n' "$1"; }

# page <ruta> : 200 o 308 canonical y contiene la landing
page() {
  local out code loc
  out=$(curl -s -L -w '\n%{http_code}' "$BASE$1"); code=$(printf '%s' "$out" | tail -n1)
  if [ "$code" = "200" ] && printf '%s' "$out" | grep -q 'class="slider-section"'; then ok "$1 → landing (200)"; else bad "$1 → esperado landing 200, obtenido $code"; fi
}
# asset <ruta> <content-type esperado (prefijo)>
asset() {
  local code ct
  read -r code ct < <(curl -s -o /dev/null -w '%{http_code} %{content_type}' "$BASE$1")
  if [ "$code" = "200" ] && [[ "$ct" == $2* ]]; then ok "$1 → $code $ct"; else bad "$1 → esperado 200 $2, obtenido $code $ct"; fi
}
# redirect <ruta> <destino exacto o relativo>
redirect() {
  local code loc
  read -r code loc < <(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' "$BASE$1")
  if [[ "$code" =~ ^30[1278]$ ]] && { [ "$loc" = "$2" ] || [ "$loc" = "$BASE$2" ]; }; then ok "$1 → $code $loc"; else bad "$1 → esperado 301 $2, obtenido $code $loc"; fi
}
# fallback <ruta> : la página 404 reenvía a la app por JS (conserva ruta y parámetros)
fallback() {
  local out code
  out=$(curl -s -w '\n%{http_code}' "$BASE$1"); code=$(printf '%s' "$out" | tail -n1)
  if [ "$code" = "404" ] && printf '%s' "$out" | grep -q 'window.location.replace(destino)'; then ok "$1 → 404 + reenvío JS a $APP$1"; else bad "$1 → esperado 404 con reenvío, obtenido $code"; fi
}
# links : todos los CTA de "Entrar" apuntan a la app
links() {
  local html n
  html=$(curl -s "$BASE/")
  n=$(printf '%s' "$html" | grep -o "href=\"$APP/login\"" | wc -l | tr -d ' ')
  [ "$n" = "3" ] && ok "3 botones 'Entrar a la plataforma' → $APP/login" || bad "botones a $APP/login: $n (esperado 3)"
  printf '%s' "$html" | grep -q 'href="/login"' && bad "quedó algún enlace relativo a /login" || ok "sin enlaces relativos a rutas de la app"
}

echo "Base: $BASE"
echo "— Landing";              page "/"; page "/index.html"; page "/?utm_source=test"; links
echo "— Páginas legales"
legal_page() {
  local out code
  out=$(curl -s -L -w '\n%{http_code}' "$BASE$1"); code=$(printf '%s' "$out" | tail -n1)
  if [ "$code" = "200" ] && printf '%s' "$out" | grep -q "$2"; then ok "$1 → 200 ($2)"; else bad "$1 → esperado 200 con '$2', obtenido $code"; fi
}
legal_page "/privacidad" "Política de Privacidad"
legal_page "/terminos" "Términos y Condiciones"
redirect "/politica-de-privacidad" "/privacidad"
redirect "/terminos-y-condiciones" "/terminos"
echo "— Recursos"
asset "/css/styles.css" "text/css"
asset "/js/main.js" "" # text/javascript o application/javascript, ambos válidos
asset "/img/logo-mas-sustentable.png" "image/png"
asset "/img/isotipo-mas-sustentable.png" "image/png"
asset "/img/logo-corfo.png" "image/png"
asset "/img/logo-social-renovable.png" "image/png"
asset "/robots.txt" "text/plain"
asset "/sitemap.xml" ""

echo "— Rutas antiguas de la app → 301 a app.massustentable.cl (Edge de Cloudflare)"
for r in /login /register /forgot-password /reset-password /dashboard /bienvenida /onboarding \
         /autodiagnostico /personalizacion /perfil /resultados /ranking /contenido \
         /hoja-de-ruta /informe-mensual; do
  redirect "$r" "$APP$r"
done

echo "— Rutas dinámicas (splats) → 301 a app.massustentable.cl"
redirect "/autodiagnostico/Q+Av1_12_2025/seccion/1" "$APP/autodiagnostico/Q+Av1_12_2025/seccion/1"
redirect "/onboarding/resumen" "$APP/onboarding/resumen"
redirect "/cuestionario/abc" "$APP/cuestionario/abc"

echo "— Rutas desconocidas → 404.html reenvía conservando todo"
fallback "/ruta-que-no-existe"
fallback "/otra-ruta-rara"

echo; echo "Resultado: $pass OK, $fail fallas"
[ "$fail" -eq 0 ]
