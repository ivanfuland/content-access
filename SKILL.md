---
name: content-access
description: >
  统一内容访问入口。只要涉及"看内容/提取内容/浏览平台/发帖互动"就用这个 skill，不要用 WebFetch 或 browser 自行处理。
  覆盖：查B站热门、搜知乎、看Twitter时间线、查股票行情；提取网页/PDF/YouTube字幕/B站转录/本地音视频（Whisper）/微信公众号文章/TG附件正文；发推/回复/点赞等写操作（带二次确认）。
  用户说"帮我看这个链接"、"这个视频讲什么"、"总结一下这篇文章"、"查一下B站热门"、"提取这个音频"时必须触发本 skill。
  路由策略：opencli 支持的平台优先走 opencli，非 opencli 平台走 summarize，都失败走云浏览器。
  NOT for: opencli 适配器开发（用 opencli skill）；本地纯文本文件（直接 Read）。
---

# Content Access

统一内容访问 skill。按用户意图路由：结构化浏览 → opencli；URL/文件提取 → opencli/summarize/cloud browser；写操作 → 二次确认 → opencli。

**决策由 AI agent 直接执行，无中间脚本。scripts/ 只放云浏览器脚本。**

---

## URL 预处理（进入决策流程前先执行）

| 原始格式 | 转换为 |
|---------|--------|
| `youtube.com/shorts/<id>` | `youtube.com/watch?v=<id>` |
| `youtube.com/live/<id>` | `youtube.com/watch?v=<id>` |
| `youtu.be/<id>` | `youtube.com/watch?v=<id>` |
| URL 含 `si=`/`utm_*` 参数 | 去掉无关参数，保留 `v=` |
| `twitter.com/...` | `x.com/...` |
| `mobile.twitter.com/...` | `x.com/...` |
| `m.bilibili.com/...` | `bilibili.com/...` |
| `x.com/<user>/status/<id>` | tweet-id = `<id>`（需 twitter thread 命令时提取） |

---

## 全局超时规则

**任何单个命令或 poll 循环总时间不超过 600s。**
- cloud browser session 上限 600s
- poll 最多 3 次（每次 timeout 120s），超过立即 stop session 并报错

---

## 决策流程

```
用户请求
  │
  ├─ [结构化意图] 查热门/搜索/看时间线/查股票...
  │    └─ 直接执行 opencli <site> <command>（见 capability-matrix.md）
  │
  ├─ [平台 URL] youtube.com / bilibili.com / x.com / zhihu.com ...
  │    ├─ URL 标准化（见上方规则）
  │    ├─ 查 capability-matrix.md → opencli 支持且有 URL 提取命令?
  │    │    ├─ 是 → opencli <site> <cmd> <url_or_id>
  │    │    │    └─ opencli 失败 → 见「opencli 错误处理表」
  │    │    └─ 否 → summarize --extract（见 summarize 用法）
  │    │         └─ 失败 → cloud browser（见 cloud browser 用法）
  │    │
  │    ├─ [已知非 opencli 视频平台 URL]
  │    │   douyin.com / v.qq.com / iqiyi.com / youku.com / xigua.com / tiktok.com
  │    │   weibo.com 视频帖（URL 含 /video/ 或 weibo.com/tv/）
  │    │   注：weibo.com 普通图文帖不在此列，走 summarize
  │    │    └─ ⛔ 报错：不支持该平台视频提取，建议用户手动下载后提供本地文件
  │    │
  │    └─ [微信文章] mp.weixin.qq.com
  │         └─ 直接走 cloud browser（--wechat 模式，跳过 summarize）
  │
  ├─ [通用 URL] 博客/文档/新闻/论坛...
  │    └─ summarize --extract
  │         └─ 失败 → cloud browser
  │
  ├─ [本地文件 / TG 附件]
  │    TG 附件：OpenClaw 下载后 file_path 字段即本地路径，归入此分支
  │    │
  │    ├─ .txt / .md / .html → 直接 Read（不走 summarize）
  │    ├─ .pdf → summarize --extract
  │    ├─ .mp3 / .wav / .m4a / .ogg → summarize --extract --transcriber whisper --timeout 30m
  │    ├─ .mp4 / .mov / .mkv → summarize --extract --transcriber whisper --timeout 30m
  │    └─ summarize 失败 → ⛔ 报错，建议用户手动处理
  │
  └─ [写操作] 发推 / 回复 / 点赞 / 删推 / 签到...
       └─ 二次确认（见 action-safety.md） → 确认后执行 opencli <site> <cmd>
```

---

## opencli 用法

详细命令参数见 `references/capability-matrix.md`。

```bash
# 结构化浏览
opencli <site> <command> [--option value] [-f json]

# URL 提取（以 YouTube 为例）
opencli youtube transcribe <url_or_video_id>
opencli bilibili transcribe <url_or_bvid>
opencli twitter thread <tweet-id>   # 从 tweet URL 末段提取 id
```

**-f json 推荐用于需要解析结果的场景。**

---

## opencli 错误处理表

| 错误类型 | 判断依据 | 处理方式 |
|---------|---------|---------|
| 命令不存在 / 平台不支持 | `command not found`、`Unknown command` | 降级 summarize |
| YouTube 字幕/音频不可用 | `transcriptSource=unavailable` | ⛔ 直接报错，不降级（内容源本身无字幕）|
| 登录态失效 / Cookie 过期 | `Not logged in`、`login required`、`unauthorized`、`401` | ⚠️ 提示用户：`opencli <site> login` 重新登录，不自动降级 |
| Rate limit / 请求过多 | `rate limit`、`429`、`too many requests` | 告知用户等待后重试，不降级 |
| 网络超时 | `timeout`、`connection error` | 重试一次，仍失败则降级 summarize |
| 内容不可用 / 已删除 | `not found`、`404`、`deleted` | 报错，不降级（内容本身不存在） |
| 其他未知错误 | 非以上类型 | 降级 summarize，附上原始错误信息 |

---

## summarize 用法

```bash
# 网页/文章/PDF（默认超时 2 分钟）
summarize "<URL或文件路径>" --extract --format md --verbose

# YouTube 视频（需要字幕/转录，最长 30 分钟）
summarize "<youtube_watch_url>" --extract --format md --youtube auto --verbose --timeout 30m

# 本地音视频（Whisper 转录）
summarize "<本地文件路径>" --extract --format md --transcriber whisper --verbose --timeout 30m

# 强制云端提取（普通抓取失败时）
summarize "<URL>" --extract --format md --firecrawl always --verbose
```

**--verbose 必须始终带上，防止长任务因无输出被判为卡死。**

**summarize 失败判断：**
- 返回内容为空或 < 200 字符
- 包含错误关键词：`error`、`failed`、`403`、`Access Denied`、`captcha`
- YouTube 返回 `transcriptSource=unavailable`

---

## cloud browser 用法

仅在 summarize 失败或微信文章时使用。playwright 直连 CDP。

**前置条件：**
- `BROWSER_USE_API_KEY` 环境变量已设置
- playwright 已安装（`pip install playwright`）

### 1. 创建 session

```bash
# OpenClaw 优先，纯 Claude Code 环境回退到 ~/.claude/skills/
SKILL_DIR="${OPENCLAW_SKILLS_DIR:-$HOME/.openclaw/skills}/content-access"
[ -d "$SKILL_DIR" ] || SKILL_DIR="$HOME/.claude/skills/content-access"

# 普通页面：120（默认），微信长文/Reddit 评论树：180
RESULT=$("$SKILL_DIR/scripts/cloud_browser_session.sh" 120)

# 解析 session_id 和 cdp_url
SESSION_ID=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])")
CDP_URL=$(echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['cdpUrl'])")
```

### 2. 提取内容

```bash
# 通用页面
python3 "$SKILL_DIR/scripts/cloud_browser_extract.py" "$CDP_URL" "$TARGET_URL"

# 微信文章（专用选择器）
python3 "$SKILL_DIR/scripts/cloud_browser_extract.py" "$CDP_URL" "$TARGET_URL" --wechat

# 输出 JSON: {"title": "...", "content": "...", "author": "...", "url": "..."}
```

### 3. 停止 session（必须执行）

```bash
"$SKILL_DIR/scripts/cloud_browser_stop.sh" "$SESSION_ID"
```

**cloud browser 失败 → 直接报错给用户，无进一步降级。**

---

## 输出格式化

提取成功后，按 `references/output-schema.md` 格式化输出。AI agent 自行格式化，无需脚本。

示例输出头部：
```
来源类型: 文章
平台: zhihu.com
标题: xxx
URL: https://...
作者: xxx（如有）
发布时间: 2024-01-01（如有）

（正文内容）
```

---

## 写操作安全规范

见 `references/action-safety.md`。所有写操作（post/reply/like/delete）必须经过二次确认后再执行。
