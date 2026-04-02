#!/usr/bin/env bash
set -euo pipefail

# Stop a Browser Use cloud_browser session.
# Usage: cloud_browser_stop.sh <session-id>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <session-id>" >&2
  exit 2
fi

SESSION_ID="$1"

API_KEY="${BROWSER_USE_API_KEY:-}"
if [[ -z "${API_KEY}" ]]; then
  echo "Error: BROWSER_USE_API_KEY environment variable is not set" >&2
  exit 1
fi

RESPONSE=$(curl -sS -w "\n%{http_code}" -X PATCH "https://api.browser-use.com/api/v2/browsers/${SESSION_ID}" \
  -H "X-Browser-Use-API-Key: ${API_KEY}" \
  -H 'Content-Type: application/json' \
  -d '{"action":"stop"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "Error: Browser Use API returned HTTP $HTTP_CODE: $BODY" >&2
  exit 1
fi

echo "$BODY"
