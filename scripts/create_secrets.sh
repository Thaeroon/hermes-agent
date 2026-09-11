#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=hermes

secret_exists() {
  local name="$1"

  kubectl -n "$NAMESPACE" get secret "$name" >/dev/null 2>&1
}

ensure_generated_secret() {
  local name="$1"
  local key="$2"

  if secret_exists "$name"; then
    echo "✓ Secret '$name' already exists"
    return 0
  fi

  local value
  value="$(openssl rand -hex 32)"

  echo "Creating secret '$name'..."

  kubectl -n "$NAMESPACE" create secret generic "$name" \
    --from-literal="$key=$value"

  echo "✓ Secret '$name' created"
}

ensure_hermes_env_secret() {
  local name="hermes-env"

  if ! secret_exists "$name"; then
    echo "Creating empty secret '$name'..."

    kubectl -n "$NAMESPACE" create secret generic "$name"

    echo "✓ Secret '$name' created"
  fi

  while IFS='=' read -r key value; do
    [[ "$key" == HERMES_* ]] || continue

    local secret_key="${key#HERMES_}"
    local encoded_value

    encoded_value="$(printf '%s' "$value" | base64 | tr -d '\n')"

    kubectl -n "$NAMESPACE" patch secret "$name" \
      --type='merge' \
      -p="{\"data\":{\"$secret_key\":\"$encoded_value\"}}"

    echo "  ✓ $key → $secret_key"
  done < <(env)

  echo "✓ Secret '$name' populated"
}


kubectl create namespace "$NAMESPACE" \
  --dry-run=client \
  -o yaml |
  kubectl apply -f -

ensure_generated_secret \
  searxng-secret \
  SEARXNG_SECRET

ensure_generated_secret \
  crawl4ai-secret \
  CRAWL4AI_API_TOKEN

ensure_hermes_env_secret \
  hermes-env