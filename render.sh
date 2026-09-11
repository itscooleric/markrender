#!/usr/bin/env bash
set -euo pipefail

ROOT=/work
OUTPUT_ROOT="${OUTPUT_DIR:-/work/_rendered}"
INPUT="${1:-}"
MODE="${2:-both}"

usage() {
  cat <<'USAGE'
Usage:
  render.sh <markdown-file-or-directory> [html|pdf|both]

Examples:
  render.sh docs/proposal.md both
  render.sh docs/proposal.md pdf
  render.sh . both

Outputs mirror the source tree beneath /work/_rendered.
USAGE
}

if [[ -z "$INPUT" ]]; then
  usage >&2
  exit 2
fi

case "$MODE" in
  html|pdf|both) ;;
  *)
    echo "error: mode must be html, pdf, or both" >&2
    exit 2
    ;;
esac

if [[ "$INPUT" = /* ]]; then
  TARGET="$INPUT"
else
  TARGET="$ROOT/$INPUT"
fi

if [[ ! -e "$TARGET" ]]; then
  echo "error: input not found: $INPUT" >&2
  exit 1
fi

render_one() {
  local src="$1"
  local rel base out_dir html pdf title resource_path

  if [[ "$src" == "$ROOT/"* ]]; then
    rel="${src#"$ROOT/"}"
  else
    rel="$(basename "$src")"
  fi

  base="${rel%.*}"
  out_dir="$OUTPUT_ROOT/$(dirname "$base")"
  html="$OUTPUT_ROOT/${base}.html"
  pdf="$OUTPUT_ROOT/${base}.pdf"

  mkdir -p "$out_dir"

  title="$(sed -n 's/^# //p' "$src" | head -n 1)"
  if [[ -z "$title" ]]; then
    title="$(basename "${src%.*}")"
  fi

  resource_path="$(dirname "$src"):$ROOT"

  echo "rendering: $rel"

  pandoc "$src" \
    --from='gfm+yaml_metadata_block' \
    --to=html5 \
    --standalone \
    --embed-resources \
    --resource-path="$resource_path" \
    --metadata="title=$title" \
    --css=/app/theme-dark.css \
    --highlight-style=zenburn \
    --output="$html"

  case "$MODE" in
    html)
      echo "  -> ${html#"$ROOT/"}"
      ;;
    pdf)
      weasyprint "$html" "$pdf"
      rm -f "$html"
      echo "  -> ${pdf#"$ROOT/"}"
      ;;
    both)
      weasyprint "$html" "$pdf"
      echo "  -> ${html#"$ROOT/"}"
      echo "  -> ${pdf#"$ROOT/"}"
      ;;
  esac
}

if [[ -f "$TARGET" ]]; then
  case "$TARGET" in
    *.md|*.markdown) render_one "$TARGET" ;;
    *)
      echo "error: input file must end in .md or .markdown" >&2
      exit 2
      ;;
  esac
else
  count=0
  while IFS= read -r -d '' file; do
    render_one "$file"
    count=$((count + 1))
  done < <(
    find "$TARGET" -type f \
      \( -name '*.md' -o -name '*.markdown' \) \
      ! -path "$OUTPUT_ROOT/*" \
      -print0
  )

  if [[ "$count" -eq 0 ]]; then
    echo "no Markdown files found beneath: $INPUT" >&2
    exit 1
  fi
fi
