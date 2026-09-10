#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=hermes

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NAMESPACE" create secret generic hermes-api \
  --from-literal=OPENAI_API_KEY="$OPENAI_API_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NAMESPACE" create secret generic searxng-secret \
  --from-literal=SEARXNG_SECRET='.$(openssl rand -hex 32)' \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NAMESPACE" create secret generic crawl4ai-secret \
  --from-literal=CRAWL4AI_API_TOKEN='$(openssl rand -hex 32)' \
  --dry-run=client -o yaml | kubectl apply -f -
