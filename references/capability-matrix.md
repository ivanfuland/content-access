# Content Access Capability Matrix

运行 `opencli list` 查看实时注册表；具体参数以 `opencli <adapter> --help` 为准。

---

## URL 提取速查

| 平台 | opencli 提取命令 | 说明 |
|------|----------------|------|
| YouTube | `youtube transcribe <url>` | plugin 命令；降级 `youtube transcript <video_id>` |
| Bilibili | `bilibili transcribe <url\|bvid>` | plugin 命令；降级 `bilibili subtitle <bvid>` |
| Twitter/X | `twitter thread <tweet-id>` | tweet-id 取 URL 末段数字 |
| V2EX | `v2ex topic --id <topic_id>` | topic_id 取 URL `/t/<id>` |
| Reddit | — | URL 正文提取直接 cloud_browser（见 exceptions.md）|
| 微信文章 | — | 直接 cloud_browser --wechat（见 exceptions.md）|
| 其他平台 URL | — | summarize --extract |

---

## 已验证平台（参数格式可信）

以下平台已在生产中验证过命令格式，参数可直接使用。

---

### Twitter / X

| 操作 | 命令 | 参数 |
|------|------|------|
| 时间线 | `twitter timeline` | `--limit N` |
| 热门话题 | `twitter trending` | `--limit N` |
| 搜索 | `twitter search` | `--query <str>`, `--limit N` |
| 书签 | `twitter bookmarks` | `--limit N` |
| 通知 | `twitter notifications` | `--limit N` |
| 用户推文 | `twitter profile` | `--username <handle>`, `--limit N` |
| 粉丝/关注列表 | `twitter followers` / `twitter following` | `--user <handle>`, `--limit N` |
| 推文线程 | `twitter thread` | `<tweet-id>` |
| 发推 ⚠️ | `twitter post` | `--text <str>` |
| 回复 ⚠️ | `twitter reply` | `--url <tweet_url>`, `--text <str>` |
| 点赞 ⚠️ | `twitter like` | `--url <tweet_url>` |
| 删推 ⚠️ | `twitter delete` | `--url <tweet_url>` |

---

### Bilibili（B站）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门 | `bilibili hot` | `--limit N` |
| 排行榜 | `bilibili ranking` | `--limit N` |
| 搜索 | `bilibili search` | `--keyword <str>`, `--type video\|user`, `--page N`, `--limit N` |
| 关注动态 | `bilibili feed` | `--limit N`, `--type all\|video\|article` |
| 用户动态 | `bilibili dynamic` | `--limit N` |
| 观看历史 | `bilibili history` | `--limit N` |
| 收藏夹 | `bilibili favorite` | `--limit N`, `--page N` |
| 关注列表 | `bilibili following` | `--uid <id>`, `--page N`, `--limit N` |
| 个人资料 | `bilibili me` | — |
| 用户投稿 | `bilibili user-videos` | `--uid <id>`, `--limit N` |
| 字幕（原生）| `bilibili subtitle` | `<bvid>` |
| 下载 ⚠️ | `bilibili download` | — |
| 视频转录（plugin）| `bilibili transcribe` | `<url\|bvid>`（需 opencli-plugin-transcribe）|

---

### YouTube

| 操作 | 命令 | 参数 |
|------|------|------|
| 搜索 | `youtube search` | `--query <str>`, `--limit N` |
| 视频详情 | `youtube video` | — |
| 字幕（原生）| `youtube transcript` | `<video_id>` |
| 视频转录（plugin）| `youtube transcribe` | `<url\|video_id>`（需 opencli-plugin-transcribe）|

---

### 知乎（Zhihu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热榜 | `zhihu hot` | `--limit N` |
| 搜索 | `zhihu search` | `--keyword <str>`, `--limit N` |
| 问题详情 | `zhihu question` | `--id <question_id>`, `--limit N` |

---

### 小红书（Xiaohongshu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 首页推荐 | `xiaohongshu feed` | `--limit N` |
| 搜索 | `xiaohongshu search` | `--keyword <str>`, `--limit N` |
| 通知 | `xiaohongshu notifications` | `--type mentions\|likes\|connections`, `--limit N` |
| 用户笔记 | `xiaohongshu user` | `--id <user_id>`, `--limit N` |
| 发布 ⚠️ | `xiaohongshu publish` | — |

注：视频笔记 URL → 报错不支持提取（同视频平台策略）

---

### 微博（Weibo）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热搜榜 | `weibo hot` | `--limit N` |
| 搜索 | `weibo search` | `--query <str>`, `--limit N` |

注：视频帖（URL 含 `/video/` 或 `/tv/`）→ 报错；普通图文帖 → summarize

---

### 雪球（Xueqiu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门动态 | `xueqiu hot` | `--limit N` |
| 热门股票 | `xueqiu hot-stock` | `--limit N`, `--type 10\|12` |
| 关注动态 | `xueqiu feed` | `--page N`, `--limit N` |
| 搜索 | `xueqiu search` | `--query <str>`, `--limit N` |
| 股票行情 | `xueqiu stock` | `--symbol <code>`（如 SH600519, AAPL）|
| 自选股 | `xueqiu watchlist` | `--category 1\|2\|3`, `--limit N` |

---

### V2EX

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门 | `v2ex hot` | `--limit N` |
| 最新 | `v2ex latest` | `--limit N` |
| 主题详情 | `v2ex topic` | `--id <topic_id>` |
| 个人资料 | `v2ex me` | — |
| 每日签到 ⚠️ | `v2ex daily` | — |
| 通知 | `v2ex notifications` | `--limit N` |

---

### BOSS直聘

| 操作 | 命令 | 参数 |
|------|------|------|
| 职位搜索 | `boss search` | `--query <str>`, `--city`, `--experience`, `--degree`, `--salary`, `--page N`, `--limit N` |
| 打招呼 ⚠️ | `boss greet` | — |
| 发消息 ⚠️ | `boss send` | — |

---

### HackerNews（无需登录）

支持：`top`, `new`, `best`, `ask`, `show`, `jobs`, `search`, `user`

---

### Yahoo Finance（无需登录）

| 操作 | 命令 | 参数 |
|------|------|------|
| 股票行情 | `yahoo-finance quote` | `--symbol <ticker>`（如 AAPL, MSFT）|

---

### BBC（无需登录）

支持：`news`

---

### Reddit

| 操作 | 命令 | 参数 |
|------|------|------|
| 首页 | `reddit frontpage` | `--limit N` |
| 热门 | `reddit hot` | `--subreddit`, `--limit N` |
| 搜索 | `reddit search` | `--query <str>`, `--limit N` |
| 指定 subreddit | `reddit subreddit` | `--name <sub>`, `--sort hot\|new\|top\|rising`, `--limit N` |

注：Reddit URL 正文提取 → 直接 cloud_browser（见 exceptions.md → allowed_direct_tier3）

---

## 其他平台（命令列表，参数以 --help 为准）

### 浏览器 Adapter

| Adapter | 支持命令 |
|---------|---------|
| `linkedin` | `search`, `timeline` |
| `instagram` | `explore`, `search`, `profile`, `user`, `followers`, `following`, `follow`, `unfollow`, `like`, `unlike`, `comment`, `save`, `unsave`, `saved` |
| `tiktok` | `explore`, `search`, `profile`, `user`, `following`, `follow`, `unfollow`, `like`, `unlike`, `comment`, `save`, `unsave`, `live`, `notifications`, `friends` |
| `facebook` | `feed`, `profile`, `search`, `friends`, `groups`, `events`, `notifications`, `memories`, `add-friend`, `join-group` |
| `medium` | `feed`, `search`, `user` |
| `substack` | `feed`, `search`, `publication` |
| `pixiv` | `ranking`, `search`, `user`, `illusts`, `detail`, `download` |
| `douban` | `search`, `top250`, `subject`, `photos`, `download`, `marks`, `reviews`, `movie-hot`, `book-hot` |
| `weread` | `shelf`, `search`, `book`, `ranking`, `notebooks`, `highlights`, `notes` |
| `jike` | `feed`, `search`, `post`, `topic`, `user`, `create`, `comment`, `like`, `repost`, `notifications` |
| `bloomberg` | `main`, `markets`, `economics`, `industries`, `tech`, `politics`, `businessweek`, `opinions`, `feeds`, `news` |
| `36kr` | `news`, `hot`, `search`, `article` |
| `sinablog` | `hot`, `search`, `article`, `user` |
| `google` | `news`, `search`, `suggest`, `trends` |
| `tieba` | `hot`, `posts`, `search`, `read` |
| `weixin` | `download` — ⚠️ 仅限附件下载，非正文提取。微信文章正文走 cloud_browser --wechat（见 exceptions.md）|
| `coupang` | `search`, `add-to-cart` |
| `ctrip` | `search` |
| `reuters` | `search` |
| `smzdm` | `search` |
| `jimeng` | `generate`, `history` |
| `yollomi` | `generate`, `video`, `edit`, `upload`, `models`, `remove-bg`, `upscale`, `face-swap`, `restore`, `try-on`, `background`, `object-remover` |
| `linux-do` | `feed`, `categories`, `tags`, `search`, `topic`, `user-topics`, `user-posts` |
| `chaoxing` | `assignments`, `exams` |
| `grok` | `ask` |
| `gemini` | `new`, `ask`, `image` |
| `notebooklm` | `status`, `list`, `open`, `select`, `current`, `get`, `metadata`, `source-list`, `source-get`, `source-fulltext`, `source-guide`, `history`, `note-list`, `notes-list`, `notes-get`, `summary` |
| `doubao` | `status`, `new`, `send`, `read`, `ask`, `history`, `detail`, `meeting-summary`, `meeting-transcript` |
| `producthunt` | `posts`, `today`, `hot`, `browse` |
| `ones` | `login`, `me`, `token-info`, `tasks`, `my-tasks`, `task`, `worklog`, `logout` |
| `jd` | `item` |
| `amazon` | `bestsellers`, `search`, `product`, `offer`, `discussion` |
| `imdb` | `search`, `title`, `top`, `trending`, `person`, `reviews` |
| `web` | `read` |

### 公共 API Adapter（均无需登录）

| Adapter | 支持命令 |
|---------|---------|
| `devto` | `top`, `tag`, `user` |
| `dictionary` | `search`, `synonyms`, `examples` |
| `apple-podcasts` | `search`, `episodes`, `top` |
| `xiaoyuzhou` | `podcast`, `podcast-episodes`, `episode` |
| `arxiv` | `search`, `paper` |
| `barchart` | `quote`, `options`, `greeks`, `flow` |
| `hf` | `top` |
| `sinafinance` | `news` |
| `spotify` | `auth`, `status`, `play`, `pause`, `next`, `prev`, `volume`, `search`, `queue`, `shuffle`, `repeat` |
| `stackoverflow` | `hot`, `search`, `bounties`, `unanswered` |
| `wikipedia` | `search`, `summary`, `random`, `trending` |
| `lobsters` | `hot`, `newest`, `active`, `tag` |
| `steam` | `top-sellers` |
| `paperreview` | `submit`, `review`, `feedback` |

### 桌面 Adapter（CDP 控制本地 App）

| Adapter | 支持命令 |
|---------|---------|
| `Cursor` | `status`, `send`, `read`, `new`, `dump`, `composer`, `model`, `extract-code`, `ask`, `screenshot`, `history`, `export` |
| `Codex` | `status`, `send`, `read`, `new`, `extract-diff`, `model`, `ask`, `screenshot`, `history`, `export` |
| `Antigravity` | `status`, `send`, `read`, `new`, `dump`, `extract-code`, `model`, `watch` |
| `ChatGPT` | `status`, `new`, `send`, `read`, `ask` |
| `ChatWise` | `status`, `new`, `send`, `read`, `ask`, `model`, `history`, `export`, `screenshot` |
| `Notion` | `status`, `search`, `read`, `new`, `write`, `sidebar`, `favorites`, `export` |
| `Discord` | `status`, `send`, `read`, `channels`, `servers`, `search`, `members` |
| `Doubao App` | `status`, `new`, `send`, `read`, `ask`, `screenshot`, `dump` |

---

## 不支持视频提取的平台

见 `exceptions.md` → `unsupported_video_extraction`。
