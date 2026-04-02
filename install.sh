#!/usr/bin/env bash
set -euo pipefail

# 安装或同步 content-access skill
# 用法: ./install.sh [目标目录]
# 默认目标: ~/.openclaw/skills/content-access

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-$HOME/.openclaw/skills/content-access}"

echo "Syncing content-access skill to $DEST ..."

rsync -a --delete \
  --exclude='README.md' \
  --exclude='install.sh' \
  --exclude='.git/' \
  --exclude='.gitignore' \
  "$SCRIPT_DIR/" "$DEST/"

# Claude Code 软链（仅 OpenClaw 用户需要）
CC_LINK="$HOME/.claude/skills/content-access"
if [ -d "$HOME/.openclaw" ] && [ ! -e "$CC_LINK" ]; then
  ln -s "$DEST" "$CC_LINK"
  echo "Created symlink: $CC_LINK -> $DEST"
fi

echo "Done."
