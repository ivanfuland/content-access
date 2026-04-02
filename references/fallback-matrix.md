# Fallback Matrix — cloud_browser

cloud_browser 是 Tier 3，最终兜底。触发时 **必须** 在输出的 `fallback_reason` 字段记录触发原因。

---

## 触发条件枚举（fallback_reason）

| 值 | 含义 | 典型场景 |
|----|------|---------|
| `js_heavy` | 页面依赖 JS 渲染，静态抓取拿不到正文 | 微信文章、SPA 应用 |
| `auth_required` | 页面需要登录态，summarize 无法访问 | 付费内容、会员专区 |
| `anti_bot` | 反爬机制，summarize 被封锁 | Reddit、某些新闻站 |
| `summarize_failed` | summarize 已执行但内容为空或质量不达标 | 通用降级 |
| `content_incomplete` | summarize 返回了内容但明显截断或缺失关键部分 | 长文章、评论区 |

每次触发 Tier 3，输出 schema 里的 `fallback_reason` 必须填入上表其中一个值。

---

## 允许直接走 Tier 3 的白名单

见 `exceptions.md` → `allowed_direct_tier3`。
不在白名单中的场景，必须先走 Tier 2 失败后才能进入 Tier 3。

---

## cloud_browser 用法

**前置条件：** `BROWSER_USE_API_KEY` 已设置，playwright 已安装。

**超时规则：** session 上限 600s；poll 最多 3 次（每次 120s），超过立即 stop 并报错。

```bash
SKILL_DIR="${OPENCLAW_SKILLS_DIR:-$HOME/.openclaw/skills}/content-access"
[ -d "$SKILL_DIR" ] || SKILL_DIR="$HOME/.claude/skills/content-access"

# 1. 创建 session
#    普通页面用 120s；微信长文 / Reddit 评论树用 180s
RESULT=$("$SKILL_DIR/scripts/cloud_browser_session.sh" 120)   # 普通页面
# RESULT=$("$SKILL_DIR/scripts/cloud_browser_session.sh" 180) # 微信 / Reddit
SESSION_ID=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])")
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdpUrl'])")

# 2. 提取内容
python3 "$SKILL_DIR/scripts/cloud_browser_extract.py" "$CDP_URL" "$TARGET_URL"           # 通用
python3 "$SKILL_DIR/scripts/cloud_browser_extract.py" "$CDP_URL" "$TARGET_URL" --wechat  # 微信

# 输出 JSON: {"title": "...", "content": "...", "author": "...", "url": "..."}

# 3. 停止 session（必须执行，释放资源）
"$SKILL_DIR/scripts/cloud_browser_stop.sh" "$SESSION_ID"
```

**Tier 3 失败 → 直接报错给用户，无进一步降级。**
