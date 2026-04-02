# content-access

统一内容访问 skill，适用于 [OpenClaw](https://github.com/ivanfuland/openclaw) 和 [Claude Code](https://claude.ai/code)。

整合 opencli、summarize、cloud browser 三条路径，按输入类型自动路由，无需手动选择工具。

## 能做什么

- **浏览平台内容**：查 B 站热门、搜知乎、看 Twitter 时间线、查股票行情……
- **提取任意来源正文**：网页、PDF、YouTube 字幕、B 站转录、本地音视频（Whisper）、微信公众号文章、TG 附件
- **平台写操作**：发推、回复、点赞、删推（带二次确认）

## 路由策略

```
用户请求
  ├─ 结构化意图（查热门/搜索）     → opencli
  ├─ 平台 URL（YouTube/B站/X）    → opencli transcribe/thread
  ├─ 通用 URL（博客/文档/新闻）    → summarize --extract → cloud browser
  ├─ 微信文章                      → cloud browser --wechat（直接）
  ├─ 本地文件 / TG 附件            → Read(.txt/.md) / summarize(.pdf/.mp3/.mp4)
  ├─ 已知视频平台（抖音/爱奇艺等） → ⛔ 报错，不支持
  └─ 写操作                        → 二次确认 → opencli
```

决策完全由 AI agent 基于 SKILL.md 执行，无 Python 路由脚本。

## 依赖

| 工具 | 说明 |
|------|------|
| [opencli](https://github.com/ivanfuland/opencli) | 平台内容 CLI，16 个站点 55+ 命令 |
| [@steipete/summarize](https://github.com/steipete/summarize) | 网页/PDF/音视频提取，`npm i -g @steipete/summarize` |
| [playwright](https://playwright.dev/) | 云浏览器 CDP 连接，`pip install playwright` |
| [Browser Use](https://browser-use.com/) | 云端浏览器服务，需 API Key |

## 安装

```bash
# 1. 克隆到本地
git clone https://github.com/ivanfuland/content-access.git ~/.openclaw/skills/content-access

# 或软链已有目录
ln -s /path/to/content-access ~/.openclaw/skills/content-access

# 2. Claude Code 注册
ln -s ~/.openclaw/skills/content-access ~/.claude/skills/content-access

# 3. 设置 Browser Use API Key
export BROWSER_USE_API_KEY="your_key_here"
# 或写入 ~/.bashrc / openclaw.json env 字段
```

## 环境变量

| 变量 | 说明 |
|------|------|
| `BROWSER_USE_API_KEY` | Browser Use 云浏览器 API Key，必须设置 |

## 文件结构

```
content-access/
├── SKILL.md                        # 决策引擎：路由规则、命令用法、超时约束
├── references/
│   ├── capability-matrix.md        # 16 个平台能力矩阵，URL 提取默认命令
│   ├── output-schema.md            # 统一输出格式规范
│   └── action-safety.md            # 写操作二次确认流程
└── scripts/
    ├── cloud_browser_session.sh    # 创建 Browser Use session
    ├── cloud_browser_extract.py    # CDP 提取页面正文（支持微信专用选择器）
    └── cloud_browser_stop.sh       # 停止 session（必须执行，释放资源）
```

## 使用示例

直接在对话中描述意图，skill 自动触发：

```
查一下 B 站热门
提取这个 YouTube 视频的字幕：https://youtube.com/watch?v=xxx
提取这篇微信文章：https://mp.weixin.qq.com/s/xxx
帮我看一下这个网页：https://blog.example.com/xxx
发一条推文："hello world"
```

## 支持平台

opencli 覆盖：Bilibili、YouTube、Twitter/X、知乎、微博、小红书、Reddit、HackerNews、V2EX、雪球、BOSS直聘、BBC、路透社、携程、什么值得买、Yahoo Finance

cloud browser 兜底：微信公众号、反爬站点、任意需要真实浏览器的页面

## 不支持

- 抖音、腾讯视频、爱奇艺、优酷、西瓜视频、TikTok 的视频提取（建议下载后以本地文件提交）
- opencli 适配器开发（用 opencli skill）
- 本地纯文本文件（直接 Read）
