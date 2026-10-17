#!/usr/bin/env bash
# Verkleinert ein Foto mit Hugo und legt es als WebP in static/pix/ ab.
# Aufruf: scripts/bild.sh originale/foto.jpg rezeptname [breite]
set -euo pipefail

src=${1:?Quelldatei fehlt}
name=${2:?Zielname fehlt (ohne Endung)}
width=${3:-800}
root=$(cd "$(dirname "$0")/.." && pwd)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/assets" "$tmp/layouts"
ext=${src##*.}
cp "$src" "$tmp/assets/in.$ext"
echo "baseURL = '/'" > "$tmp/hugo.toml"
cat > "$tmp/layouts/index.html" <<TPL
{{ with resources.Get "in.${ext}" }}{{ \$i := .Resize "${width}x webp q80" }}{{ \$i.Publish }}{{ \$i.RelPermalink }}{{ end }}
TPL

hugo --source "$tmp" --destination "$tmp/out" --quiet
out=$(find "$tmp/out" -name '*.webp' | head -1)
[ -n "$out" ] || { echo "Konvertierung fehlgeschlagen" >&2; exit 1; }
cp "$out" "$root/static/pix/$name.webp"
echo "static/pix/$name.webp ($(du -h "$root/static/pix/$name.webp" | cut -f1))"
