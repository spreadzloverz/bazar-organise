#!/usr/bin/env bash
# Fabrique la version web de GPS NIMBUS, prête à être déposée telle quelle
# sur n'importe quel hébergeur statique (GitHub Pages, Netlify, un dossier
# de site existant…).
#
#   ./tool/build_web.sh              → build dans build/web
#   ./tool/build_web.sh ../nimbus    → build puis copie dans ../nimbus
#
# Deux réglages sont appliqués après la compilation :
#
#  1. `<base href="./">` — le site fonctionne quel que soit le sous-dossier
#     où il est déposé, sans avoir à recompiler.
#  2. `canvasKitBaseUrl` local — le moteur de rendu est servi depuis le même
#     hébergeur, et non depuis un CDN tiers. Plus rapide, et l'application
#     ne dépend de personne d'autre.

set -euo pipefail

cd "$(dirname "$0")/.."
DEST="${1:-}"

flutter build web --release --no-web-resources-cdn

python3 - <<'PY'
from pathlib import Path

index = Path('build/web/index.html')
html = index.read_text(encoding='utf-8')
html = html.replace('<base href="/">', '<base href="./">')
html = html.replace('<title>gps_nimbus</title>', '<title>GPS NIMBUS</title>')
html = html.replace('content="gps_nimbus"', 'content="GPS NIMBUS"')
index.write_text(html, encoding='utf-8')

bootstrap = Path('build/web/flutter_bootstrap.js')
source = bootstrap.read_text(encoding='utf-8')
needle = '_flutter.loader.load({'
assert needle in source, 'flutter_bootstrap.js a changé de forme'
source = source.replace(
    needle,
    needle + '\n  config: { canvasKitBaseUrl: "canvaskit/" },',
    1,
)
bootstrap.write_text(source, encoding='utf-8')
print('index.html et flutter_bootstrap.js ajustés')
PY

# Les fichiers de symboles ne servent qu'au débogage du moteur de rendu.
find build/web -name '*.symbols' -delete

# Flutter livre aussi le moteur « skwasm », qui n'est utilisé que par les
# compilations WebAssembly. Ce build utilise CanvasKit (voir _flutter.buildConfig
# dans flutter_bootstrap.js) : ces 8 Mo ne seraient jamais téléchargés, mais ils
# alourdissent inutilement l'hébergement.
find build/web/canvaskit -name 'skwasm*' -delete

if [ -n "$DEST" ]; then
  rm -rf "$DEST"
  mkdir -p "$DEST"
  cp -r build/web/. "$DEST/"
  echo "Version web copiée dans $DEST"
fi

echo "Taille : $(du -sh build/web | cut -f1)"
