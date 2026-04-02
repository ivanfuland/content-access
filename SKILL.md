---
name: content-access
description: >
  内容访问路由层。将用户的内容访问请求路由到正确的 provider。
  Tier 1 opencli：结构化浏览 / 搜索 / 热榜 / timeline / feed / history / bookmarks / profile / 写操作。
  Tier 2 summarize：正文提取 / 全文 / transcript / PDF / 音视频 / 附件。
  Tier 3 cloud_browser：仅作最终兜底，summarize 失败或 exceptions.md 白名单场景。
  触发：帮我看这个链接、查B站热门、提取这篇文章、发条推文、这视频讲什么。
  Also triggers on: extract this article, summarize this page, what's trending, fetch content from URL, read this link, transcribe this video, post a tweet, check hot topics.
  禁止跳级：能走 Tier 1 不得先走 Tier 2；Tier 2 未失败不得走 Tier 3。例外见 exceptions.md 白名单。
  NOT for: opencli 适配器开发（用 opencli skill）；纯文本文件读取（直接 Read）。
---

# Content Access — Router

**这是路由层，不是 provider。** 职责是决策走哪条链路，不自己实现提取逻辑。

---

## 路由层级（严格顺序，禁止跳级——例外见 `exceptions.md`）

```
Tier 1  opencli          结构化命令、写操作
   ↓ 仅在 Tier 1 无法覆盖或明确失败时
Tier 2  summarize        正文提取、PDF、音视频转录
   ↓ 仅在 Tier 2 失败时
Tier 3  cloud_browser    最终兜底，触发原因必须显式记录
```

**白名单例外**：`exceptions.md` 中 `allowed_direct_tier3` 列出的域名允许跳过 Tier 2 直进 Tier 3；`unsupported_video_extraction` 列出的域名视频提取直接报错（结构化浏览不受影响）。

---

## 意图 → Tier 映射

| 意图类型 | Tier | 备注 |
|---------|------|------|
| 搜索 / 热榜 / timeline / feed / history / bookmarks / profile / trending | Tier 1 | opencli 结构化命令 |
| 正文 / 全文 / transcript / PDF / 音视频 / 附件 | Tier 2 | summarize 提取 |
| 发帖 / 回复 / 点赞 / 收藏 / 签到 | Tier 1 + **confirm required** | 见 write-safety.md |
| 平台 URL | 查 capability-matrix.md 速查 → Tier 1 或降级 | 见 routing-rules.md |

---

## 输出

所有路由结果统一输出 schema，见 `references/output-schema.md`。
必填字段：`intent`、`route`、`provider_command`、`source_type`、`platform`、`title`；`content` 和 `transcript` 至少填一个。

---

## 参考文档

| 文件 | 内容 |
|------|------|
| `references/routing-rules.md` | 路由细则、URL 预处理、意图判断、summarize 用法、超时规则 |
| `references/exceptions.md` | 白名单例外：允许直跳 Tier 3 的域名、不支持视频提取的平台、易混淆能力消歧 |
| `references/fallback-matrix.md` | cloud_browser 触发条件、fallback_reason 枚举、脚本用法 |
| `references/capability-matrix.md` | opencli 平台命令（60+ adapter）|
| `references/output-schema.md` | 统一输出格式规范 |
| `references/write-safety.md` | 写操作确认流程与模板 |
| `references/routing-acceptance.md` | 路由验收用例（8 个场景，验证合同一致性）|
