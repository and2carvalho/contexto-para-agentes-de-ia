#!/usr/bin/env bash
# Gera as cartilhas (carrosséis em PDF para o LinkedIn) a partir dos arquivos .typ.
set -euo pipefail
cd "$(dirname "$0")"
for f in cartilha-*.typ; do
  typst compile --root .. --font-path ../fontes "$f" "${f%.typ}.pdf"
  echo "gerado: divulgacao/${f%.typ}.pdf"
done
