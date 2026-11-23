#!/bin/sh
set -eu
# JSON escaping via node is unavailable in nginx image; use envsubst with a safe URL check.
case "${VITE_API_URL:-}" in
  https://*|http://*) ;;
  *) echo "ERRO: configure VITE_API_URL com a URL pública da API (incluindo /api)" >&2; exit 1 ;;
esac
case "$VITE_API_URL" in
  *[!a-zA-Z0-9:/._?=\&%-]*) echo "ERRO: VITE_API_URL contém caracteres inválidos" >&2; exit 1 ;;
esac
printf 'window.__APP_CONFIG__ = { API_URL: "%s" };\n' "$VITE_API_URL" > /usr/share/nginx/html/config.js
