#!/usr/bin/env bash
# Compila o livro "Contexto para Agentes de IA".
# Requisitos: Typst >= 0.15 (https://typst.app) e Python 3 (para os índices gerados).
#
# Uso:
#   ./build.sh                                   edição aberta (licença CC BY-NC-ND 4.0)
#   LICENCIADO="nome ou e-mail" ./build.sh       exemplar com identificação nominal ou institucional no rodapé
set -euo pipefail
cd "$(dirname "$0")"
python3 ferramentas/gerar_indices.py .
python3 ferramentas/gerar_glossario.py .
if [ -n "${LICENCIADO:-}" ]; then
  slug=$(printf '%s' "$LICENCIADO" | tr -c 'A-Za-z0-9._-' '_')
  saida="exemplar-${slug}.pdf"
  typst compile --root . --font-path fontes --input licenciado="$LICENCIADO" livro.typ "$saida"
else
  saida="contexto-para-agentes-de-ia.pdf"
  typst compile --root . --font-path fontes livro.typ "$saida"
fi
echo "PDF gerado: $(pwd)/$saida"
