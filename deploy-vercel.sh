#!/usr/bin/env bash
#
# deploy-vercel.sh — Build and deploy ai-video-editor to Vercel.
#
# Usage:
#   ./deploy-vercel.sh              # production deploy
#   ./deploy-vercel.sh --preview    # preview (branch) deploy
#
# Prerequisites:
#   npm install -g vercel            # or: npx vercel
#   vercel login                     # authenticate first time
#
# Environment variables (optional):
#   VERCEL_TOKEN     – API token for CI/CD (skip interactive login)
#   VERCEL_ORG_ID    – Org/team scope
#   VERCEL_PROJECT_ID – Project scope (once linked)
#   VERCEL_DOMAIN    – Custom domain to alias after deploy
#
set -euo pipefail

cd "$(dirname "$0")"

# ── parse flags ──────────────────────────────────────────────
PREVIEW=false
for arg in "$@"; do
  case "$arg" in
    --preview) PREVIEW=true ;;
    -h|--help)
      echo "Usage: $0 [--preview]"
      exit 0 ;;
  esac
done

# ── install deps if needed ──────────────────────────────────
if [ ! -d node_modules ]; then
  echo "▶ Installing dependencies …"
  npm ci
fi

# ── type-check + lint ───────────────────────────────────────
echo "▶ Running checks …"
npm run check

# ── build ───────────────────────────────────────────────────
echo "▶ Building for production …"
npm run build

# ── deploy ──────────────────────────────────────────────────
DEPLOY_ARGS=("--yes")
if [ "${VERCEL_TOKEN:-}" != "" ]; then
  DEPLOY_ARGS+=("--token" "$VERCEL_TOKEN")
fi

if [ "$PREVIEW" = true ]; then
  echo "▶ Deploying preview …"
  npx vercel "${DEPLOY_ARGS[@]}" --no-prod
else
  echo "▶ Deploying to production …"
  npx vercel "${DEPLOY_ARGS[@]}" --prod
fi

# ── optional: alias custom domain ──────────────────────────
if [ "${VERCEL_DOMAIN:-}" != "" ]; then
  echo "▶ Aliasing to $VERCEL_DOMAIN …"
  ALIAS_ARGS=("--alias" "$VERCEL_DOMAIN")
  if [ "${VERCEL_TOKEN:-}" != "" ]; then
    ALIAS_ARGS+=("--token" "$VERCEL_TOKEN")
  fi
  npx vercel "${ALIAS_ARGS[@]}"
fi

echo "✅ Deploy complete!"
