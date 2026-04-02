# Content Access 统一输出格式规范

AI agent 提取内容后，自行按此规范格式化输出。无需脚本，直接文本格式化。

---

## 字段定义

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `source_type` | string | ✅ | 内容类型：`article` / `video` / `tweet` / `pdf` / `audio` / `podcast` / `post` / `thread` |
| `platform` | string | ✅ | 来源平台或域名，如 `youtube.com`、`bilibili.com`、`zhihu.com`、`local` |
| `title` | string | ✅ | 内容标题 |
| `url` | string | 条件必填 | 原始 URL（本地文件时可省略）|
| `path` | string | 条件必填 | 本地文件路径（URL 内容时可省略）|
| `author` | string | 可选 | 作者/创作者/账号名 |
| `published_at` | string | 可选 | 发布时间（ISO 8601 或自然语言，如 `2024-01-15`）|
| `content` | string | 条件必填 | 正文文本内容（文章/网页/PDF 提取结果）|
| `transcript` | string | 条件必填 | 转录文本（音视频内容）|
| `metadata` | object | 可选 | 附加信息（时长、字数、语言、转录方式等）|

`content` 和 `transcript` 至少有一个必填。

---

## 各 Provider 字段映射

### opencli youtube transcribe / bilibili transcribe

```
source_type: video
platform:    youtube.com / bilibili.com
title:       命令输出的视频标题
url:         标准化后的 watch URL / BV 链接
author:      UP主/频道名（如有）
transcript:  命令输出的转录文本
metadata:    { transcription_method: "caption" | "whisper", language: "<lang>" }
```

### opencli twitter thread

```
source_type: tweet
platform:    x.com
title:       推文首行（前 50 字符）或 "<用户名> 的推文"
url:         https://x.com/<user>/status/<tweet-id>
author:      @用户名
content:     推文正文（含线程所有推文拼接）
published_at: 推文时间（如命令提供）
```

### summarize（网页/文章/PDF）

```
source_type: article / pdf
platform:    从 URL 提取域名，或 "local"（本地文件）
title:       summarize 输出的标题
url:         原始 URL（如有）
path:        本地文件路径（如有）
author:      文章作者（如 summarize 提取到）
published_at: 发布时间（如 summarize 提取到）
content:     summarize 提取的正文 markdown
```

### summarize（音视频转录）

```
source_type: audio / video / podcast
platform:    "local"
title:       文件名（去掉路径和扩展名）
path:        本地文件路径
transcript:  summarize Whisper 转录结果
metadata:    { transcription_method: "whisper", file_format: ".mp3/.mp4/..." }
```

### cloud browser（通用）

```
source_type: article
platform:    从 TARGET_URL 提取域名
title:       cloud_browser_extract.py 返回的 title
url:         TARGET_URL
content:     cloud_browser_extract.py 返回的 content
```

### cloud browser（微信文章）

```
source_type: article
platform:    mp.weixin.qq.com
title:       cloud_browser_extract.py 返回的 title
url:         TARGET_URL
author:      cloud_browser_extract.py 返回的 author（公众号名）
content:     cloud_browser_extract.py 返回的 content
```

---

## 输出呈现格式

AI agent 格式化为可读文本，头部附加元信息，正文紧随其后：

```
来源类型: <source_type>
平台: <platform>
标题: <title>
URL: <url>（本地文件时省略）
路径: <path>（URL 内容时省略）
作者: <author>（无则省略整行）
发布时间: <published_at>（无则省略整行）

（正文 content 或 transcript 内容）
```

**省略规则**：可选字段若为空，整行不输出。必填字段若提取失败，标注 `（未获取）`。
