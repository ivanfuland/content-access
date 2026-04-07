# Routing Rules

content-access 路由细则。所有路由决策依此执行，禁止跳级。

---

## URL 预处理（进入路由前执行）

| 原始格式 | 转换为 |
|---------|--------|
| `youtube.com/shorts/<id>` | `youtube.com/watch?v=<id>` |
| `youtube.com/live/<id>` | `youtube.com/watch?v=<id>` |
| `youtu.be/<id>` | `youtube.com/watch?v=<id>` |
| URL 含 `si=` / `utm_*` 参数 | 去掉无关参数，保留 `v=` |
| `twitter.com/...` | `x.com/...` |
| `mobile.twitter.com/...` | `x.com/...` |
| `m.bilibili.com/...` | `bilibili.com/...` |
| `x.com/<user>/status/<id>` | tweet-id = `<id>`，内容类型由用户意图决定（见下方 Twitter 意图分流规则）|

---

## 意图识别 → Tier 路由

### Tier 1 触发（opencli）

用户表达以下意图时，直接走 opencli，不经过 summarize：

- 搜索内容：「搜一下」「查一下」「找 XX」
- 浏览列表：热榜 / 热门 / trending / timeline / feed / history / bookmarks / ranking
- 个人页面：profile / following / followers / me / notifications
- 查询型：股票行情 / 职位列表 / 论坛帖子列表
- 平台 URL 且 capability-matrix 有对应提取命令

**执行格式：**
```bash
opencli <site> <command> [--option value] [-f json]
```
`-f json` 用于需要解析结果的场景。

### Tier 2 触发（summarize）

用户表达以下意图时，或 Tier 1 失败后降级：

- 正文提取：「帮我看这篇文章」「提取内容」「全文」
- URL 但 capability-matrix 无对应提取命令
- 本地 PDF 文件
- 本地音视频文件（Whisper 转录）
- TG 附件（OpenClaw 下载后归为本地路径）

**不走 Tier 2 的情况**（均为 `exceptions.md` 白名单）：
- YouTube / Bilibili URL → Tier 1（plugin 命令）
- `exceptions.md` → `allowed_direct_tier3` 列出的域名直接 Tier 3
- `exceptions.md` → `unsupported_video_extraction` 列出的域名直接报错

### Tier 3 触发（cloud_browser）

仅在以下情况允许：见 `fallback-matrix.md` 和 `exceptions.md`。

---

## 决策流程

```
用户请求
  │
  ├─ [例外检查] 查 exceptions.md
  │    ├─ unsupported_video_extraction 命中 → ⛔ 直接报错（不进任何 Tier）
  │    └─ allowed_direct_tier3 命中 → 直接 Tier 3（记录 fallback_reason）
  │
  ├─ 意图识别 → Tier 1 意图（搜索/热榜/列表）
  │    └─ opencli <site> <command>
  │         └─ 失败 → 见 opencli 错误处理
  │
  ├─ 平台 URL
  │    ├─ URL 预处理
  │    ├─ 查 capability-matrix.md 速查表
  │    │    ├─ Twitter x.com/*/status/<id> → 见 Twitter/X status URL 意图分流章节
  │    │    ├─ 有 opencli 提取命令 → Tier 1
  │    │    │    └─ 失败 → 见 opencli 错误处理
  │    │    └─ 无 opencli 提取命令 → Tier 2
  │    │         └─ 失败 → Tier 3
  │    │
  │    └─ [Reddit 结构化浏览] reddit.com + 搜索/热门/subreddit 意图 → Tier 1
  │
  ├─ 通用 URL（博客/文档/新闻/论坛）
  │    └─ Tier 2 → 失败 → Tier 3
  │
  ├─ 本地文件 / TG 附件
  │    ├─ .txt / .md / .html → 直接 Read（不进 Tier）
  │    ├─ .pdf → Tier 2
  │    ├─ .mp3 / .wav / .m4a / .ogg / .mp4 / .mov / .mkv → Tier 2（Whisper）
  │    └─ Tier 2 失败 → ⛔ 报错，建议手动处理
  │
  └─ 写操作（发帖 / 回复 / 点赞 / 收藏 / 签到）
       └─ confirm required（见 write-safety.md） → Tier 1
```

---

## Twitter/X status URL 意图分流

`x.com/<user>/status/<id>` 的 URL 外壳相同，但内部内容类型不同（短推 / 长文 Article / 视频推文 / 线程入口）。
**不能仅凭 URL 形态决定路由**，必须结合用户意图：

```
x.com/<user>/status/<id>
  ├─ 用户意图含"评论/回复/线程/讨论" → opencli twitter thread <tweet-id>
  └─ 其他默认正文类意图（"帮我看/提取/全文/存 md/帮我看这个链接"）
        └─ opencli twitter article <tweet-id>
              └─ 失败（空内容 / 无 title 或 content / 明确非 article）
                    → 降级 opencli twitter thread <tweet-id>
```

**article 失败判断标准**（以下任一满足即降级）：
- 返回空内容或纯空白
- 无法提取 title 和 content 中的任何一个
- 命令输出明确包含"not an article"、"no article content"等提示

**注意：** article 降级到 thread 属于 Tier 1 内部 fallback，不触发 Tier 2/3。

---

## YouTube / Bilibili 转录（特殊 Tier 1 分支）

转录命令由 opencli-plugin-transcribe 提供，属于 Tier 1：

- URL 转录 → `opencli youtube transcribe <url>` / `opencli bilibili transcribe <url>`
- plugin 不可用时 → YouTube 降级 `youtube transcript`，Bilibili 降级 `bilibili subtitle`
- `transcriptSource=unavailable` → 内容源无字幕，**直接报错**，不降级 Tier 2

---

## opencli 错误处理

| 错误 | 判断依据 | 处理方式 |
|------|---------|---------|
| 命令不存在 / 平台不支持（读取型 URL 提取）| `command not found`、`Unknown command` | 降级 Tier 2 |
| 命令不存在 / 平台不支持（结构化浏览：搜索/热榜/列表/feed）| `command not found`、`Unknown command` | ⛔ 报错，不降级（summarize 无法提供等价结构化结果）|
| YouTube 内容不可用 | `transcriptSource=unavailable` | ⛔ 直接报错，不降级 |
| 登录态失效 | `Not logged in`、`login required`、`401` | 提示 `opencli <site> login`，不降级 |
| Rate limit | `rate limit`、`429`、`too many requests` | 告知用户等待，不降级 |
| 网络超时 | `timeout`、`connection error` | 重试一次，仍失败降级 Tier 2 |
| 内容不可用 / 已删除 | `not found`、`404`、`deleted` | ⛔ 报错，不降级 |
| 其他未知错误（读取型请求）| — | 降级 Tier 2，附原始错误 |
| 其他未知错误（结构化浏览：搜索/热榜/列表/feed）| — | ⛔ 报错，不降级（降级后语义会变）|

---

## Tier 2（summarize）用法

```bash
# URL / 文章 / PDF
summarize "<URL或文件路径>" --extract --format md --verbose

# 本地音视频（Whisper 转录）
summarize "<本地文件路径>" --extract --format md --transcriber whisper --verbose --timeout 30m

# 普通抓取失败时强制云端
summarize "<URL>" --extract --format md --firecrawl always --verbose
```

`--verbose` 必须始终带上，防止长任务因无输出被判为卡死。

**超时分层：**

| 场景 | 超时 |
|------|------|
| 普通 URL / 文章 / PDF | 120s（summarize 默认）|
| 本地音视频（Whisper） | 1800s（`--timeout 30m`）|

**Tier 2 失败判断及 fallback_reason 映射：**

| 失败类型 | 判断依据 | → fallback_reason |
|---------|---------|-------------------|
| 空内容 | 返回空字符串或纯空白 | `summarize_failed` |
| 错误页 | 包含 `error`、`failed`、`403`、`Access Denied`、`captcha`、`blocked` | `summarize_failed` |
| 关键字段缺失 | 无法提取 title 和 content 中的任何一个 | `summarize_failed` |
| 内容残缺/截断 | 有内容但缺少标题且正文仅含导航/菜单片段，或明显截断 | `content_incomplete` |

注意：短内容（公告、摘要、短帖）不算失败。不要用字符数阈值判断。

---

## 不支持视频提取的平台

见 `exceptions.md` → `unsupported_video_extraction`。
