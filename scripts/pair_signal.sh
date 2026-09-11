#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="hermes"
SERVICE="signal-cli-signal-cli"
LOCAL_PORT="18080"
LINK_NAME="HermesAgent"

PF_LOG="$(mktemp)"
PF_PID=""

cleanup() {
    if [[ -n "$PF_PID" ]]; then
        kill "$PF_PID" 2>/dev/null || true
        wait "$PF_PID" 2>/dev/null || true
    fi

    rm -f "$PF_LOG"
}

trap cleanup EXIT INT TERM

echo "Starting port-forward..."

kubectl -n "$NAMESPACE" port-forward \
    "svc/$SERVICE" \
    "$LOCAL_PORT:8080" \
    >"$PF_LOG" 2>&1 &

PF_PID=$!

echo -n "Waiting for signal-cli"

until curl -fsS \
    --max-time 1 \
    "http://127.0.0.1:$LOCAL_PORT/api/v1/check" \
    >/dev/null 2>&1
do
    if ! kill -0 "$PF_PID" 2>/dev/null; then
        echo
        echo "ERROR: port-forward exited:"
        cat "$PF_LOG"
        exit 1
    fi

    echo -n "."
    sleep 1
done

echo " ready."

echo "Requesting Signal linking URI..."

RESPONSE="$(
    curl -fsS \
        --max-time 10 \
        -X POST \
        "http://127.0.0.1:$LOCAL_PORT/api/v1/rpc" \
        -H 'Content-Type: application/json' \
        -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"startLink\",
            \"params\": {
                \"deviceName\": \"$LINK_NAME\"
            },
            \"id\": \"1\"
        }"
)"

LINK_URI="$(
    printf '%s' "$RESPONSE" |
    sed -n 's/.*"deviceLinkUri"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
)"

if [[ -z "$LINK_URI" ]]; then
    echo
    echo "ERROR: Signal did not return a linking URI." >&2
    exit 1
fi

echo
echo "============================================================"
echo "Signal linking URI"
echo "============================================================"
echo
printf '%s\n' "$LINK_URI"
echo
echo "============================================================"

if command -v qrencode >/dev/null 2>&1; then
    echo
    echo "QR code:"
    echo

    printf '%s' "$LINK_URI" | qrencode -t UTF8

    echo
    echo "Scan the QR code with:"
    echo
    echo "  Signal → Settings → Linked Devices → Link New Device"
    echo
else
    echo
    echo "qrencode is not installed, so no QR code was generated."
    echo
    echo "install qrencode with you favorite package manager to get a QR code."
    echo
fi

echo "Waiting for Signal to approve the new linked device..."
echo

FINISH_RESPONSE="$(
    curl -fsS \
        --max-time 300 \
        -X POST \
        "http://127.0.0.1:$LOCAL_PORT/api/v1/rpc" \
        -H 'Content-Type: application/json' \
        -d "{
            \"jsonrpc\": \"2.0\",
            \"method\": \"finishLink\",
            \"params\": {
                \"deviceLinkUri\": \"$LINK_URI\",
                \"deviceName\": \"$LINK_NAME\"
            },
            \"id\": \"finish-link\"
        }"
)"

if printf '%s' "$FINISH_RESPONSE" |
    grep -q '"error"'
then
    echo "ERROR: Signal linking failed." >&2
    exit 1
fi

echo
echo "Signal linking completed."
echo
echo "Accounts currently configured:"
echo

curl -fsS \
    --max-time 10 \
    -X POST \
    "http://127.0.0.1:$LOCAL_PORT/api/v1/rpc" \
    -H 'Content-Type: application/json' \
    -d '{
        "jsonrpc": "2.0",
        "method": "listAccounts",
        "id": "list-accounts"
    }'

echo
echo
echo "Done."
