# 路由例外规则

主合同：Tier 1 → Tier 2 → Tier 3 严格顺序，禁止跳级。
本文件列出所有允许的例外。**不在此列表中的场景，一律走主合同。**

---

## allowed_direct_tier3 — 允许跳过 Tier 2 直接进入 Tier 3

| 域名 | fallback_reason | 原因 | 备注 |
|------|----------------|------|------|
| `mp.weixin.qq.com` | `js_heavy` | 微信文章依赖 JS 渲染，裸 HTTP 必然拿不到正文 | 使用 `cloud_browser_extract.py --wechat` |
| `reddit.com`（URL 正文提取）| `anti_bot` | 封锁裸 HTTP 请求，summarize 必然失败 | Reddit 结构化浏览（搜索/热门/subreddit）仍走 Tier 1 opencli |

新增例外必须在此表登记，并附 fallback_reason 和原因说明。

---

## unsupported_video_extraction — 不支持视频提取，直接报错

**仅限视频提取场景。** 这些平台的结构化浏览/搜索（如有 opencli adapter）不受影响，仍走正常 Tier 1 路由。

| 平台 | 域名 | 触发条件 | 不受影响的操作 |
|------|------|---------|--------------|
| 抖音 | `douyin.com` | 视频 URL | — |
| 腾讯视频 | `v.qq.com` | 视频 URL | — |
| 爱奇艺 | `iqiyi.com` | 视频 URL | — |
| 优酷 | `youku.com` | 视频 URL | — |
| 西瓜视频 | `xigua.com` | 视频 URL | — |
| TikTok | `tiktok.com` | 视频 URL | `tiktok explore/search/profile` 等浏览命令正常走 Tier 1 |
| 小红书 | `xiaohongshu.com` / `xhslink.com` | 视频笔记 URL | 图文笔记正常走 Tier 2；`xiaohongshu feed/search` 正常走 Tier 1 |
| 微博 | `weibo.com` | URL 含 `/video/` 或 `/tv/` | 图文微博正常走 Tier 2；`weibo hot/search` 正常走 Tier 1 |

报错模板：
> 不支持提取 [平台名] 的视频内容。建议将视频下载到本地后提交文件路径，我将使用 Whisper 进行转录。

---

## disambiguation — 易混淆能力消歧

| 能力 | 归属 | 说明 |
|------|------|------|
| `weixin download` | Tier 1 opencli | 下载微信文章附件（非正文提取）。微信文章正文提取的主路径是 Tier 3 `cloud_browser --wechat`，不要用 `weixin download` 替代 |
