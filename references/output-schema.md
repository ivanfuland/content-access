# Content Access 统一输出格式规范

所有路由结果统一使用此 schema。AI agent 自行格式化输出，无需脚本。

---

## 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `route` | string | ✅ | 实际走的路径：`opencli` / `summarize` / `cloud_browser` |
| `source_type` | string | ✅ | `article` / `video` / `tweet` / `pdf` / `audio` / `podcast` / `post` / `thread` |
| `platform` | string | ✅ | 来源平台或域名，如 `youtube.com`、`bilibili.com`、`local` |
| `title` | string | ✅ | 内容标题 |
| `url` | string | 条件必填 | 原始 URL（本地文件时可省略）|
| `path` | string | 条件必填 | 本地文件路径（URL 内容时可省略）|
| `author` | string | 可选 | 作者 / 创作者 / 账号名 |
| `published_at` | string | 可选 | 发布时间（ISO 8601 或自然语言）|
| `content` | string | 条件必填 | 正文文本（文章 / 网页 / PDF）|
| `summary` | string | 可选 | 内容简要摘要（50-150字），由 agent 提炼 |
| `transcript` | string | 条件必填 | 转录文本（音视频内容）|
| `metadata` | object | 可选 | 附加信息：时长、字数、语言、转录方式、命令等 |
| `fallback_reason` | string | 条件必填 | cloud_browser 触发原因，见 fallback-matrix.md 枚举值；Tier 1/2 时省略 |
| `intent` | string | ✅ | 用户原始意图的一句话归纳，如「提取微信文章正文」「搜索 B 站关键词」|
| `provider_command` | string | ✅ | 实际执行的命令或工具调用，如 `opencli youtube transcribe <url>`、`summarize "<url>" --extract`、`cloud_browser_extract.py --wechat` |

`content` 和 `transcript` 至少有一个必填。

---

## 输出呈现格式

```
意图: <intent>
路由路径: <route>
执行命令: <provider_command>
来源类型: <source_type>
平台: <platform>
标题: <title>
URL: <url>（本地文件时省略）
路径: <path>（URL 内容时省略）
作者: <author>（无则省略整行）
发布时间: <published_at>（无则省略整行）
兜底原因: <fallback_reason>（仅 cloud_browser 时输出）

（正文 content 或 transcript 内容）

摘要：<summary>（如提炼了摘要）
```

**省略规则：** 可选字段若为空，整行不输出。必填字段若提取失败，标注 `（未获取）`。

---

## 各 Provider 字段映射

### Tier 1 — opencli youtube transcribe / bilibili transcribe

```
intent:           用户意图归纳
route:            opencli
provider_command: opencli youtube transcribe <url>
source_type:      video
platform:         youtube.com / bilibili.com
title:            命令输出的视频标题
url:              标准化后的 watch URL / BV 链接
author:           UP主 / 频道名（如有）
transcript:       命令输出的转录文本
metadata:         { transcription_method: "caption" | "whisper", language: "<lang>" }
```

### Tier 1 — opencli twitter thread

```
intent:           用户意图归纳
route:            opencli
provider_command: opencli twitter thread <tweet-id>
source_type:      tweet
platform:         x.com
title:            推文首行（前 50 字符）或 "<用户名> 的推文"
url:              https://x.com/<user>/status/<tweet-id>
author:           @用户名
content:          推文正文（含线程所有推文拼接）
published_at:     推文时间（如命令提供）
```

### Tier 1 — opencli twitter article

```
intent:           用户意图归纳
route:            opencli
provider_command: opencli twitter article <tweet-id>
source_type:      article
platform:         x.com
title:            命令输出的 article 标题
url:              https://x.com/<user>/status/<tweet-id>
author:           @用户名
content:          article 正文 markdown
published_at:     推文时间（如命令提供）
```

**article 降级说明：** 若 `twitter article` 返回空内容或无法提取 title 和 content 中的任何一个，自动降级执行 `twitter thread <tweet-id>`，输出格式改为上方 `twitter thread` 的 schema。

### Tier 2 — summarize（网页 / 文章 / PDF）

```
intent:           用户意图归纳
route:            summarize
provider_command: summarize "<url>" --extract --format md --verbose
source_type:      article / pdf
platform:         从 URL 提取域名，或 "local"
title:            summarize 输出的标题
url:              原始 URL（如有）
path:             本地文件路径（如有）
author:           文章作者（如 summarize 提取到）
published_at:     发布时间（如 summarize 提取到）
content:          summarize 提取的正文 markdown
```

### Tier 2 — summarize（音视频转录）

```
intent:           用户意图归纳
route:            summarize
provider_command: summarize "<path>" --extract --format md --transcriber whisper --verbose --timeout 30m
source_type:      audio / video / podcast
platform:         "local"
title:            文件名（去掉路径和扩展名）
path:             本地文件路径
transcript:       summarize Whisper 转录结果
metadata:         { transcription_method: "whisper", file_format: ".mp3/.mp4/..." }
```

### Tier 3 — cloud_browser

```
intent:           用户意图归纳
route:            cloud_browser
provider_command: cloud_browser_extract.py "<cdp_url>" "<target_url>" [--wechat]
source_type:      article
platform:         从 TARGET_URL 提取域名
title:            cloud_browser_extract.py 返回的 title
url:              TARGET_URL
content:          cloud_browser_extract.py 返回的 content
author:           cloud_browser_extract.py 返回的 author（如有）
fallback_reason:  js_heavy / auth_required / anti_bot / summarize_failed / content_incomplete
```
