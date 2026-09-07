#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/.artifacts/GPS_NIMBUS_REPO_READY}"
ZIP_PATH="${2:-$ROOT_DIR/.artifacts/GPS_NIMBUS_REPO_READY.zip}"

rm -rf "$OUTPUT_DIR"
rm -f "$ZIP_PATH"
mkdir -p "$OUTPUT_DIR" "$(dirname "$ZIP_PATH")"

# Copie uniquement l'application Flutter et non le portfolio Bazar Organisé.
cp -a "$ROOT_DIR/gps_nimbus/." "$OUTPUT_DIR/"
rm -rf \
  "$OUTPUT_DIR/build" \
  "$OUTPUT_DIR/.dart_tool" \
  "$OUTPUT_DIR/private_data" \
  "$OUTPUT_DIR/test_private"

# Documentation et règles adaptées à un dépôt autonome.
cp -a "$ROOT_DIR/docs" "$OUTPUT_DIR/docs"
cp "$ROOT_DIR/migration/CLAUDE_STANDALONE.md" "$OUTPUT_DIR/CLAUDE.md"
cp "$ROOT_DIR/migration/MIGRATION_PAS_A_PAS.md" \
  "$OUTPUT_DIR/MIGRATION_PAS_A_PAS.md"
cp "$ROOT_DIR/migration/SOURCE_PROVENANCE.md" \
  "$OUTPUT_DIR/SOURCE_PROVENANCE.md"
cp "$ROOT_DIR/migration/DEPLOYMENT_STANDALONE.md" \
  "$OUTPUT_DIR/docs/DEPLOYMENT.md"

mkdir -p "$OUTPUT_DIR/.github/workflows"
cp "$ROOT_DIR/migration/gps-nimbus-ci-standalone.yml" \
  "$OUTPUT_DIR/.github/workflows/ci.yml"

# Les liens du README viennent initialement d'un sous-dossier.
sed -i 's#\.\./docs/#docs/#g' "$OUTPUT_DIR/README.md"

# Aucun artefact local ou secret ne doit entrer dans le paquet.
find "$OUTPUT_DIR" -type f \
  \( -name '.env' -o -name '.env.*' -o -name '*.keystore' \
     -o -name '*.jks' -o -name '*.p12' -o -name '*.mobileprovision' \) \
  ! -name '.env.example' -print -quit | grep -q . && {
    echo 'ERREUR: fichier secret ou de signature détecté.' >&2
    exit 1
  }

# Le dépôt de destination peut devenir public plus tard : les adresses exactes
# du cas terrain ne doivent pas être incluses dans le paquet.
if grep -R -I -n -E \
  '19[[:space:]]+rue[[:space:]]+Andr[eé][[:space:]]+Soladier|14[[:space:]]+rue[[:space:]]+Jules[[:space:]]+Guesde' \
  "$OUTPUT_DIR"; then
  echo 'ERREUR: adresse personnelle exacte détectée.' >&2
  exit 1
fi

# Manifeste reproductible, chemins relatifs uniquement.
(
  cd "$OUTPUT_DIR"
  find . -type f ! -name 'MANIFEST_SHA256.txt' -print0 \
    | sort -z \
    | xargs -0 sha256sum
) > "$OUTPUT_DIR/MANIFEST_SHA256.txt"

PACKAGE_PARENT="$(dirname "$OUTPUT_DIR")"
PACKAGE_NAME="$(basename "$OUTPUT_DIR")"
(
  cd "$PACKAGE_PARENT"
  zip -qr "$ZIP_PATH" "$PACKAGE_NAME"
)

printf 'Package: %s\n' "$ZIP_PATH"
printf 'Files: %s\n' "$(find "$OUTPUT_DIR" -type f | wc -l | tr -d ' ')"
printf 'SHA256: %s\n' "$(sha256sum "$ZIP_PATH" | awk '{print $1}')"
