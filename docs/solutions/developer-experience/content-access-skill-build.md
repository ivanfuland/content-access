---
title: Building a Unified Content Access Skill for OpenClaw & Claude Code
date: 2026-04-02
category: developer-experience
module: content-access
problem_type: developer_experience
component: tooling
severity: medium
applies_when:
  - Building or extending a skill that integrates multiple content providers
  - Deploying skills across OpenClaw and Claude Code environments
  - Using Browser Use cloud browser API with Playwright CDP
  - Managing API keys in skills meant to run on different machines
tags: [skill-authoring, openclaw, claude-code, browser-use, rsync, portable-paths, api-key-management]
---

# Building a Unified Content Access Skill for OpenClaw & Claude Code

## Context

Building `content-access` — a skill that routes content requests to opencli, @steipete/summarize, or Browser Use cloud browser — surfaced a set of recurring pitfalls when authoring skills for multi-environment deployment. The skill needs to run on any machine, be installable from a public git repo, and keep API keys out of config files.

## Guidance

### 1. Skill descriptions must be "pushy"

Claude undertriggers skills by default. The description must name the implicit phrases users say, not just the formal feature name.

```yaml
# weak — only matches explicit requests
description: "Unified content access via opencli, summarize, and cloud browser"

# strong — catches natural language
description: "Fetch, extract, or summarize any content: web pages, PDFs, YouTube videos,
Bilibili transcripts, WeChat articles, Twitter threads, local audio/video, Telegram attachments.
Use for any request involving 'get', 'extract', 'read', 'fetch', 'summarize', 'transcribe'
on a URL or file."
```

### 2. Never hardcode paths — use `$HOME` and env vars

Skills are published to GitHub and run on other machines. Any `/home/username/` path breaks immediately.

```bash
# wrong
SKILL_DIR="/home/ivan/.openclaw/skills/content-access"

# right — works on any machine
SKILL_DIR="${OPENCLAW_SKILLS_DIR:-$HOME/.openclaw/skills}/content-access"
[ -d "$SKILL_DIR" ] || SKILL_DIR="$HOME/.claude/skills/content-access"
```

### 3. API keys via environment variables only

Skills must not read API keys from config files (like `openclaw.json`). The skill is public; config files are user-local. Env vars are the portable contract.

```bash
API_KEY="${BROWSER_USE_API_KEY:-}"
if [[ -z "${API_KEY}" ]]; then
  echo "Error: BROWSER_USE_API_KEY environment variable is not set" >&2
  exit 1
fi
```

Users set the key in `~/.bashrc` or in `openclaw.json`'s `env` field (OpenClaw injects it automatically):

```json
{ "env": { "BROWSER_USE_API_KEY": "your_key_here" } }
```

### 4. Deploy with rsync, not cp or symlink

`~/.openclaw/skills/` requires real directories (not symlinks). `rsync -a --delete` handles both fresh installs and incremental updates, and excludes non-runtime files cleanly.

```bash
rsync -a --delete \
  --exclude='README.md' \
  --exclude='install.sh' \
  --exclude='.git/' \
  --exclude='.gitignore' \
  "$SCRIPT_DIR/" "$DEST/"
```

`~/.claude/skills/` accepts symlinks, so Claude Code users can symlink from the OpenClaw install:

```bash
CC_LINK="$HOME/.claude/skills/content-access"
if [ -d "$HOME/.openclaw" ] && [ ! -e "$CC_LINK" ]; then
  ln -s "$DEST" "$CC_LINK"
fi
```

### 5. Browser Use API returns `cdpUrl` (camelCase)

The Browser Use API response uses camelCase. Using `cdp_url` causes a `KeyError` at runtime.

```bash
# wrong — KeyError
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdp_url'])")

# right
SESSION_ID=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])")
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdpUrl'])")
```

### 6. Assign shell variables before using them

A common SKILL.md mistake: downstream variable use without the assignment line.

```bash
# missing RESULT assignment — SESSION_ID will be empty
SESSION_ID=$(echo "$RESULT" | python3 -c "...")

# correct
RESULT=$("$SKILL_DIR/scripts/cloud_browser_session.sh" 120)
SESSION_ID=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])")
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdpUrl'])")
```

### 7. Check HTTP status in curl scripts

`curl -sS` swallows HTTP errors silently. Use `-w "%{http_code}"` to capture and check the status.

```bash
RESPONSE=$(curl -sS -w "\n%{http_code}" -X POST "https://api.example.com/resource" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H 'Content-Type: application/json' \
  -d '{"key":"value"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "201" ]]; then
  echo "Error: API returned HTTP $HTTP_CODE: $BODY" >&2
  exit 1
fi
echo "$BODY"
```

### 8. Harden Python scripts with try/finally and null checks

Playwright processes must always be stopped, even on failure. And API responses can be empty.

```python
def extract(cdp_url, target_url):
    pw = sync_playwright().start()
    try:
        browser = pw.chromium.connect_over_cdp(cdp_url)
        contexts = browser.contexts
        if not contexts:
            raise RuntimeError("No browser contexts available")
        page = contexts[0].new_page()
        page.goto(target_url, wait_until='domcontentloaded', timeout=30000)
        body_el = page.query_selector('body')
        result = {
            'title': page.title(),
            'content': body_el.inner_text().strip() if body_el else '',
            'url': target_url,
        }
        browser.close()
        return result
    finally:
        pw.stop()  # always runs, even on exception
```

### 9. Use a three-tier routing strategy for content providers

For skills that integrate multiple content providers, route by input specificity:

```
User request
  ├─ Structured intent (search/browse platform)  → provider A (opencli)
  ├─ Platform URL with native support            → provider A (opencli transcribe/thread)
  ├─ Generic URL (blog/docs/news)               → provider B (summarize --extract)
  ├─ Anti-scrape site / WeChat                  → provider C (cloud browser)
  ├─ Local file                                 → Read / summarize by extension
  └─ Known-unsupported platform                 → error with explanation
```

This avoids wasted API calls: try the cheapest/most reliable provider first, escalate on failure.

### 10. Keep SKILL.md as the sole routing brain

Do not add Python router scripts or dispatch logic outside SKILL.md. The routing tree lives in SKILL.md as prose/pseudocode; Claude reads it and routes accordingly. Extra scripts add indirection without benefit.

## Why This Matters

Skills authored without these patterns either break on other machines (hardcoded paths), leak API keys (config file coupling), silently fail (no HTTP status check, no variable assignment), or never trigger (weak descriptions). Each issue requires a round-trip through install, test, debug — and compounds when the skill is public.

## When to Apply

- Authoring any skill that ships with shell scripts or Python helpers
- Publishing a skill to a public repo (GitHub)
- Skills that call external APIs
- Skills targeting both OpenClaw and Claude Code environments
- Any skill using Browser Use cloud browser API

## Examples

**Before (broken on another machine):**
```bash
SKILL_DIR="/home/ivan/.openclaw/skills/content-access"
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdp_url'])")
```

**After (portable and correct):**
```bash
SKILL_DIR="${OPENCLAW_SKILLS_DIR:-$HOME/.openclaw/skills}/content-access"
[ -d "$SKILL_DIR" ] || SKILL_DIR="$HOME/.claude/skills/content-access"
RESULT=$("$SKILL_DIR/scripts/cloud_browser_session.sh" 120)
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdpUrl'])")
```

## Related

- `content-access` skill: `~/.openclaw/skills/content-access/SKILL.md`
- Browser Use API docs: https://api.browser-use.com
- @steipete/summarize: https://github.com/steipete/summarize
