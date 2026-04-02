# content-access

统一内容访问 skill，适用于 [OpenClaw](https://github.com/ivanfuland/openclaw) 和 [Claude Code](https://claude.ai/code)。

整合 opencli、summarize、cloud browser 三条路径，按输入类型自动路由，无需手动选择工具。

## 能做什么

- **浏览平台内容**：查 B 站热门、搜知乎、看 Twitter 时间线、查股票行情……
- **提取任意来源正文**：网页、PDF、YouTube 字幕、B 站转录、本地音视频（Whisper 转录）、微信公众号文章、TG 附件
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

## 前置依赖

| 工具 | 安装方式 | 用途 |
|------|---------|------|
| Node.js 18+ | [nodejs.org](https://nodejs.org) | 运行 opencli 和 summarize |
| [opencli](https://github.com/jackwener/opencli) | `npm install -g @jackwener/opencli` | 平台内容 CLI（16 个站点）|
| [opencli-plugin-transcribe](https://github.com/ivanfuland/opencli-plugin-transcribe) | `opencli plugin install github:ivanfuland/opencli-plugin-transcribe` | YouTube/Bilibili 字幕提取（含 Whisper 回退）|
| [@steipete/summarize](https://github.com/steipete/summarize) | `npm install -g @steipete/summarize` | 网页/PDF/音视频提取 |
| Python 3.9+ | 系统自带或 [python.org](https://python.org) | 运行 cloud browser 脚本 |
| playwright | `pip install playwright` + `playwright install chromium` | 云浏览器 CDP 连接 |
| [Browser Use](https://browser-use.com/) 账号 | 注册后获取 API Key | 云端浏览器服务 |

## 安装

### 1. 安装依赖

```bash
# opencli
npm install -g @jackwener/opencli

# transcribe 插件（YouTube/Bilibili 字幕）
opencli plugin install github:ivanfuland/opencli-plugin-transcribe

# summarize
npm install -g @steipete/summarize

# playwright
pip install playwright
playwright install chromium
```

### 2. 克隆并安装 skill

```bash
git clone https://github.com/ivanfuland/content-access.git
cd content-access
./install.sh
```

`install.sh` 会自动：
- 将 skill 文件同步到 `~/.openclaw/skills/content-access`（排除 README、.git 等非 runtime 文件）
- 检测到 OpenClaw 时自动创建 Claude Code 软链 `~/.claude/skills/content-access`

**Claude Code only 用户（无 OpenClaw）：**
```bash
./install.sh ~/.claude/skills/content-access
```

后续更新：
```bash
git pull && ./install.sh
```

### 4. 设置 Browser Use API Key

```bash
# 持久化写入 ~/.bashrc（或 ~/.zshrc）
echo 'export BROWSER_USE_API_KEY="your_key_here"' >> ~/.bashrc
source ~/.bashrc
```

OpenClaw 用户也可写入 `openclaw.json` 的 `env` 字段，OpenClaw 会自动注入：

```json
{
  "env": {
    "BROWSER_USE_API_KEY": "your_key_here"
  }
}
```

### 5. 验证安装

```bash
# 确认 skill 可访问
ls ~/.claude/skills/content-access/SKILL.md

# 确认 summarize 可用
summarize --version

# 确认环境变量已设置
echo $BROWSER_USE_API_KEY
```

## 使用

直接在 Claude Code 对话中描述意图，skill 自动触发，无需显式调用：

```
查一下 B 站热门
提取这个 YouTube 视频的字幕：https://youtube.com/watch?v=xxx
提取这篇微信文章：https://mp.weixin.qq.com/s/xxx
帮我看一下这个网页：https://blog.example.com/xxx
发一条推文："hello world"
```

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

## 支持平台

opencli 覆盖：Bilibili、YouTube、Twitter/X、知乎、微博、小红书、Reddit、HackerNews、V2EX、雪球、BOSS直聘、BBC、路透社、携程、什么值得买、Yahoo Finance

cloud browser 兜底：微信公众号、反爬站点、任意需要真实浏览器的页面

## 不支持

- 抖音、腾讯视频、爱奇艺、优酷、西瓜视频、TikTok 的视频提取（建议下载到本地后以文件路径提交）
- opencli 适配器开发（用 opencli skill）
- 本地纯文本文件读取（直接 Read 即可）
