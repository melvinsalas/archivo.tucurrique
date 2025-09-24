#!/usr/bin/env zsh
# Recorre _files y crea .md espejo en _minutes con front matter.
# Uso:
#   chmod +x make_minutes.sh
#   ./make_minutes.sh [ruta_del_proyecto]

set -euo pipefail

BASE_DIR="${1:-.}"
FILES_DIR="$BASE_DIR/_files"
MINUTES_DIR="$BASE_DIR/_minutes"

if [[ ! -d "$FILES_DIR" ]]; then
  echo "Error: no existe la carpeta $FILES_DIR"
  exit 1
fi

mkdir -p "$MINUTES_DIR"

# Función: normaliza espacios (reemplaza _ por espacio y colapsa múltiples espacios)
normalize_spaces() {
  local s="$1"
  # Reemplaza guiones bajos por espacio, colapsa espacios múltiples y recorta extremos
  print -r -- "$s" | sed -E 's/_/ /g; s/[[:space:]]+/ /g; s/^[[:space:]]+|[[:space:]]+$//g'
}

# Función: Title Case (respeta acentos)
title_case() {
  perl -CSD -pe 's/\b(\p{L})(\p{L}*)/\u$1\L$2/g'
}

# Función: slugify (minúsculas, guiones, sin acentos)
slugify() {
  # 1) translitera a ASCII (quita acentos), 2) pasa a minúsculas,
  # 3) reemplaza no alfanumérico por guiones, 4) quita guiones extremos
  iconv -f UTF-8 -t ASCII//TRANSLIT | tr '[:upper:]' '[:lower:]' | \
    sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# Recorre todos los PDFs (case-insensitive)
find "$FILES_DIR" -type f -iname "*.pdf" -print0 | while IFS= read -r -d '' PDF_PATH; do
  # Ruta relativa respecto a _files
  REL_PATH="${PDF_PATH#"$FILES_DIR"/}"
  BASENAME_WITH_EXT="$(basename "$REL_PATH")"
  BASENAME_NO_EXT="${BASENAME_WITH_EXT%.*}"

  # Determina directorio espejo en _minutes
  TARGET_MD="$MINUTES_DIR/${REL_PATH%.*}.md"
  mkdir -p "$(dirname "$TARGET_MD")"

  if [[ -e "$TARGET_MD" ]]; then
    echo "Saltado (ya existe): $TARGET_MD"
    continue
  fi

  # Nombre "limpio" para procesar (normaliza espacios)
  CLEAN_NAME="$(normalize_spaces "$BASENAME_NO_EXT")"

  # title (Title Case)
  TITLE="$(print -r -- "$CLEAN_NAME" | title_case)"

  # type: segunda palabra en minúsculas; si no hay, "general"
  # Split por espacios
  SECOND_WORD="$(print -r -- "$CLEAN_NAME" | awk '{print $2}')"
  if [[ -n "${SECOND_WORD:-}" ]]; then
    TYPE_FIELD="$(print -r -- "$SECOND_WORD" | tr '[:upper:]' '[:lower:]')"
  else
    TYPE_FIELD="general"
  fi

  # date: toma el primer directorio (p. ej., "2025") bajo _files si es YYYY; si no, 2025
  FIRST_DIR="$(print -r -- "$REL_PATH" | awk -F/ '{print $1}')"
  if print -r -- "$FIRST_DIR" | grep -Eq '^[0-9]{4}$'; then
    DATE_FIELD="$FIRST_DIR-01-01"
  else
    DATE_FIELD="2025"
  fi

  # file: ruta pública al PDF
  FILE_FIELD="/files/$REL_PATH"

  # permalink: slug del nombre del archivo sin extensión
  PERMALINK_SLUG="$(print -r -- "$CLEAN_NAME" | slugify)"
  PERMALINK="actas/$PERMALINK_SLUG"

  # Escribe el front matter en el .md
  cat > "$TARGET_MD" <<EOF
---
title: $TITLE
type: $TYPE_FIELD
date: $DATE_FIELD
file: $FILE_FIELD
permalink: $PERMALINK
---
EOF

  echo "Creado: $TARGET_MD"
done

echo "Hecho. Front matter generado en _minutes."
