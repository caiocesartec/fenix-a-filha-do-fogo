#!/usr/bin/env bash
# Uso: após `gh auth login -h github.com`, execute: ./deploy-github.sh [nome-do-repo]
set -euo pipefail
cd "$(dirname "$0")"
REPO_NAME="${1:-fenix-a-filha-do-fogo}"

if ! gh auth status &>/dev/null; then
  echo "GitHub CLI não está autenticado."
  echo "Execute: gh auth login -h github.com"
  exit 1
fi

OWNER="$(gh api user --jq .login)"

if git remote get-url origin &>/dev/null; then
  echo "Remote origin já existe; enviando commits..."
  git push -u origin main
else
  gh repo create "$REPO_NAME" \
    --private \
    --source=. \
    --remote=origin \
    --push \
    --description "Fênix: A Filha do Fogo – The Best (site estático)"
fi

echo "Ativando GitHub Pages (branch main, raiz do repositório)..."
if gh api -X POST "repos/${OWNER}/${REPO_NAME}/pages" \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/ 2>/dev/null; then
  echo "Pages solicitado com sucesso."
else
  echo "Não foi possível ativar Pages via API (talvez já exista). Se precisar, em:"
  echo "  https://github.com/${OWNER}/${REPO_NAME}/settings/pages"
  echo "  escolha Deploy from a branch → main → / (root) → Save."
fi

echo ""
echo "Repositório (privado): https://github.com/${OWNER}/${REPO_NAME}"
echo "Site público (GitHub Pages): https://${OWNER}.github.io/${REPO_NAME}/"
echo "(O deploy pode levar 1–3 minutos na primeira vez.)"
