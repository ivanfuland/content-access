# 路由验收集

验证路由决策是否符合合同。每个用例需能解释：为什么走这条路径，为什么不走其他路径。

---

## 用例

### 1. 微信文章

```
输入: https://mp.weixin.qq.com/s/abc123
期望路由: Tier 3 cloud_browser --wechat
fallback_reason: js_heavy
合同依据: exceptions.md → allowed_direct_tier3
解释: 微信文章依赖 JS 渲染，裸 HTTP 必然拿不到正文，不经 Tier 2 直接进 Tier 3。
```

### 2. Reddit URL 正文

```
输入: https://www.reddit.com/r/programming/comments/abc123/some_post
期望路由: Tier 3 cloud_browser
fallback_reason: anti_bot
合同依据: exceptions.md → allowed_direct_tier3
解释: Reddit 封锁裸 HTTP，summarize 必然失败。注意：如果意图是「搜索 Reddit」或「看 r/programming 热门」则走 Tier 1 opencli。
```

### 3. 普通博客

```
输入: https://blog.example.com/2026/04/some-article
期望路由: Tier 2 summarize → 成功则停；失败则 Tier 3
fallback_reason: （Tier 2 成功时无；失败时 summarize_failed 或 content_incomplete）
合同依据: routing-rules.md → 通用 URL 走 Tier 2
解释: 非 exceptions.md 白名单域名，capability-matrix 无 opencli 提取命令，走主合同 Tier 2。
```

### 4. X 线程

```
输入: https://x.com/elonmusk/status/1234567890
期望路由: Tier 1 opencli twitter thread 1234567890
合同依据: capability-matrix.md → Twitter URL 提取速查
解释: URL 预处理提取 tweet-id，capability-matrix 有对应命令，直接 Tier 1。
```

### 5. 本地 PDF

```
输入: /home/user/documents/report.pdf
期望路由: Tier 2 summarize --extract
合同依据: routing-rules.md → 本地文件 .pdf → Tier 2
解释: 本地 PDF 文件，summarize 支持提取。失败则报错建议手动处理（不降级 Tier 3）。
```

### 6. 短公告页

```
输入: https://example.com/notice（返回内容仅 50 字符的简短公告）
期望路由: Tier 2 summarize → 成功
合同依据: routing-rules.md → Tier 2 失败判断
解释: 短内容不算失败。不用字符数阈值判断，公告内容完整即为成功，不触发降级。
```

### 7. TikTok 视频 URL

```
输入: https://www.tiktok.com/@user/video/1234567890
期望路由: ⛔ 直接报错
合同依据: exceptions.md → unsupported_video_extraction
解释: TikTok 视频提取不支持。注意：「搜索 TikTok 热门」走 Tier 1 opencli tiktok explore，不受此限制。
```

### 8. 小红书视频笔记 URL

```
输入: https://www.xiaohongshu.com/explore/video_note_id
期望路由: ⛔ 直接报错
合同依据: exceptions.md → unsupported_video_extraction
解释: 小红书视频笔记不支持提取。图文笔记走 Tier 2 summarize，「搜索小红书」走 Tier 1 opencli，均不受影响。
```

---

## 验收标准

每个用例的路由输出必须包含：
- `intent`：用户原始意图归纳
- `route`：实际走的路径
- `provider_command`：实际执行的命令
- 如走 Tier 3：`fallback_reason` 必须填入 fallback-matrix.md 枚举值
- 能回答「为什么没走其他路径」
