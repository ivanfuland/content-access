#!/usr/bin/env bash
set -euo pipefail

# Create a Browser Use cloud browser session.
# Returns JSON with session_id and cdp_url.
#
# Usage: cloud_browser_session.sh [TIMEOUT_SECONDS]
#   TIMEOUT_SECONDS: 云端浏览器存活时长（秒），默认 120。
#     普通页面建议 120；微信长文/Reddit 评论树等复杂页面建议 180。
#
# API key: 读取环境变量 BROWSER_USE_API_KEY，未设置则报错退出。

TIMEOUT="${1:-120}"

API_KEY="${BROWSER_USE_API_KEY:-}"
if [[ -z "${API_KEY}" ]]; then
  echo "Error: BROWSER_USE_API_KEY environment variable is not set" >&2
  exit 1
fi

curl -sS -X POST 'https://api.browser-use.com/api/v2/browsers' \
  -H "X-Browser-Use-API-Key: ${API_KEY}" \
  -H 'Content-Type: application/json' \
  -d "{\"timeout\":${TIMEOUT}}"
