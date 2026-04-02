# content-access

统一内容访问 skill，适用于 [OpenClaw](https://github.com/ivanfuland/openclaw) 和 [Claude Code](https://claude.ai/code)。

整合 opencli、summarize、cloud_browser 三条路径，按输入类型自动路由，无需手动选择工具。

## 能做什么

- **浏览平台内容**：查 B 站热门、搜知乎、看 Twitter 时间线、查股票行情……
- **提取任意来源正文**：网页、PDF、YouTube 字幕、B 站转录、本地音视频（Whisper 转录）、微信公众号文章、TG 附件
- **平台写操作**：发推、回复、点赞、删推（带二次确认）

## 路由策略

Tier 1 opencli → Tier 2 summarize → Tier 3 cloud_browser，严格顺序降级。
白名单例外和不支持视频提取的平台见 `references/exceptions.md`。
完整路由规则见 `SKILL.md` + `references/routing-rules.md`。

## 前置依赖

| 工具 | 安装方式 | 用途 |
|------|---------|------|
| Node.js 18+ | [nodejs.org](https://nodejs.org) | 运行 opencli 和 summarize |
| [opencli](https://github.com/jackwener/opencli) | `npm install -g @jackwener/opencli` | 平台内容 CLI（60+ adapter）|
| [opencli-plugin-transcribe](https://github.com/ivanfuland/opencli-plugin-transcribe) | `opencli plugin install github:ivanfuland/opencli-plugin-transcribe` | YouTube/Bilibili 字幕提取（含 Whisper 回退）|
| [@steipete/summarize](https://github.com/steipete/summarize) | `npm install -g @steipete/summarize` | 网页/PDF/音视频提取 |
| Python 3.9+ | 系统自带或 [python.org](https://python.org) | 运行 cloud_browser 脚本 |
| playwright | `pip install playwright` + `playwright install chromium` | cloud_browser CDP 连接 |
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

### 3. 设置 Browser Use API Key

```bash
# 写入 shell 环境（推荐）
echo 'export BROWSER_USE_API_KEY="your_key_here"' >> ~/.bashrc
source ~/.bashrc
```

OpenClaw 用户可选写入 `openclaw.json` 的 `env` 字段（非必须，shell env 优先）。

### 4. 验证安装

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
├── SKILL.md                        # 路由层入口：层级定义、意图映射、参考文档索引
├── references/
│   ├── routing-rules.md            # 路由细则、URL 预处理、决策流程、错误处理
│   ├── exceptions.md               # 白名单例外：直跳 Tier 3、不支持视频提取、消歧
│   ├── fallback-matrix.md          # cloud_browser 触发条件、脚本用法
│   ├── capability-matrix.md        # 平台能力矩阵（60+ adapter）、URL 提取命令
│   ├── output-schema.md            # 统一输出格式规范
│   ├── write-safety.md             # 写操作二次确认流程
│   └── routing-acceptance.md       # 路由验收用例（8 场景）
└── scripts/
    ├── cloud_browser_session.sh    # 创建 Browser Use session
    ├── cloud_browser_extract.py    # CDP 提取页面正文（支持微信专用选择器）
    └── cloud_browser_stop.sh       # 停止 session（必须执行，释放资源）
```

## 平台覆盖

opencli 60+ adapter（浏览器/API/桌面三类），详见 `references/capability-matrix.md`。
不支持视频提取的平台和白名单例外，详见 `references/exceptions.md`。
