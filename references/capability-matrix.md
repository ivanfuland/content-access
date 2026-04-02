# Content Access Capability Matrix

opencli 基准版本：**1.5.7**

## 说明

- **URL 提取默认命令**：用户给出平台 URL 要获取内容时，优先执行的 opencli 命令
- **Fallback**：opencli 失败时的降级路径
- **✅** = 支持 **—** = 不适用 **⚠️** = 需登录

---

## 平台能力矩阵

### BBC

| 操作 | 命令 | 参数 | URL 提取 |
|------|------|------|---------|
| 新闻头条 | `bbc news` | `--limit N` | — |

URL 提取默认命令：无（BBC 文章 URL → summarize --extract）

---

### Bilibili（B站）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门视频 | `bilibili hot` | `--limit N` |
| 排行榜 | `bilibili ranking` | `--limit N` |
| 搜索 | `bilibili search` | `--keyword <str>`, `--type video\|user`, `--page N`, `--limit N` |
| 关注动态 | `bilibili feed` | `--limit N`, `--type all\|video\|article` |
| 用户动态 | `bilibili dynamic` | `--limit N` |
| 观看历史 | `bilibili history` | `--limit N` |
| 收藏夹 | `bilibili favorite` | `--limit N`, `--page N` |
| 关注列表 | `bilibili following` | `--uid <id>`, `--page N`, `--limit N` |
| 个人资料 | `bilibili me` | — |
| 用户投稿 | `bilibili user-videos` | `--uid <id>`, `--limit N`, `--order pubdate\|click\|stow` |
| **视频转录** | `bilibili transcribe` | `<url\|bvid>` (位置参数), `--lang`, `--mode raw\|grouped`, `--force-asr`, `--keep-audio` |

**URL 提取默认命令**：`bilibili transcribe <url_or_bvid>`（字幕优先，Whisper large-v3 兜底）
Fallback：opencli 不支持 → summarize --extract

---

### BOSS直聘

| 操作 | 命令 | 参数 |
|------|------|------|
| 职位搜索 | `boss search` | `--query <str>`, `--city`, `--experience`, `--degree`, `--salary`, `--page N`, `--limit N` |

URL 提取默认命令：无（职位详情 URL → summarize --extract）

---

### 携程（Ctrip）

| 操作 | 命令 | 参数 |
|------|------|------|
| 搜索城市/景点 | `ctrip search` | `--query <str>`, `--limit N` |

URL 提取默认命令：无（景点页面 → summarize --extract）

---

### HackerNews

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门故事 | `hackernews top` | `--limit N`（无需登录）|

URL 提取默认命令：无（HN 帖子/外链 → summarize --extract）

---

### Reddit

| 操作 | 命令 | 参数 |
|------|------|------|
| 首页 | `reddit frontpage` | `--limit N` |
| 热门帖子 | `reddit hot` | `--subreddit`, `--limit N` |
| 搜索 | `reddit search` | `--query <str>`, `--limit N` |
| 指定 subreddit | `reddit subreddit` | `--name <subreddit>`, `--sort hot\|new\|top\|rising`, `--limit N` |

URL 提取默认命令：无（Reddit 帖子 URL → summarize 会被封锁 → 直接 cloud browser）
**注意**：Reddit 封锁裸 HTTP，summarize 失败后直接走 cloud browser。

---

### 路透社（Reuters）

| 操作 | 命令 | 参数 |
|------|------|------|
| 新闻搜索 | `reuters search` | `--query <str>`, `--limit N`（无需登录）|

URL 提取默认命令：无（Reuters 文章 URL → summarize --extract）

---

### 什么值得买（smzdm）

| 操作 | 命令 | 参数 |
|------|------|------|
| 商品搜索 | `smzdm search` | `--keyword <str>`, `--limit N` |

URL 提取默认命令：无（商品页 → summarize --extract）

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
| 粉丝列表 | `twitter followers` | `--user <handle>`, `--limit N` |
| 关注列表 | `twitter following` | `--user <handle>`, `--limit N` |
| 发推 ⚠️ | `twitter post` | `--text <str>` |
| 回复 ⚠️ | `twitter reply` | `--url <tweet_url>`, `--text <str>` |
| 点赞 ⚠️ | `twitter like` | `--url <tweet_url>` |
| 删推 ⚠️ | `twitter delete` | `--url <tweet_url>` |
| **单推文线程** | `twitter thread` | `<tweet-id>` (位置参数) |

**URL 提取默认命令**：`twitter thread <tweet-id>` ⚠️ 待验证（commands.md v1.5.7 未列出此命令，若不存在则降级 summarize）
tweet-id 提取方式：`x.com/<user>/status/<tweet-id>` → 取 URL 末段数字串
Fallback：opencli 失败或命令不存在 → summarize --extract

---

### V2EX

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门话题 | `v2ex hot` | `--limit N`（无需登录）|
| 最新话题 | `v2ex latest` | `--limit N`（无需登录）|
| 主题详情 | `v2ex topic` | `--id <topic_id>` |
| 个人资料 | `v2ex me` | — |
| 每日签到 ⚠️ | `v2ex daily` | — |
| 通知 | `v2ex notifications` | `--limit N` |

URL 提取默认命令：`v2ex topic --id <topic_id>`（从 URL `/t/<id>` 提取 id）
Fallback：summarize --extract

---

### 微博（Weibo）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热搜榜 | `weibo hot` | `--limit N` |

URL 提取默认命令：无（微博帖子 URL → summarize --extract）
**注意**：weibo.com 视频帖子属于"已知视频平台"，报错不提取（见下方域名清单）

---

### 小红书（Xiaohongshu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 首页推荐 | `xiaohongshu feed` | `--limit N` |
| 搜索笔记 | `xiaohongshu search` | `--keyword <str>`, `--limit N` |
| 通知 | `xiaohongshu notifications` | `--type mentions\|likes\|connections`, `--limit N` |
| 用户笔记 | `xiaohongshu user` | `--id <user_id>`, `--limit N` |

URL 提取默认命令：无（小红书笔记 URL → summarize --extract）
**注意**：xiaohongshu.com / xhslink.com 视频笔记属于"已知视频平台"，报错不提取

---

### 雪球（Xueqiu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门动态 | `xueqiu hot` | `--limit N` |
| 热门股票 | `xueqiu hot-stock` | `--limit N`, `--type 10\|12` |
| 关注动态 | `xueqiu feed` | `--page N`, `--limit N` |
| 搜索股票 | `xueqiu search` | `--query <str>`, `--limit N` |
| 股票行情 | `xueqiu stock` | `--symbol <code>`（如 SH600519, AAPL）|
| 自选股 | `xueqiu watchlist` | `--category 1\|2\|3`, `--limit N` |

URL 提取默认命令：无（雪球帖子 → summarize --extract）

---

### Yahoo Finance

| 操作 | 命令 | 参数 |
|------|------|------|
| 股票行情 | `yahoo-finance quote` | `--symbol <ticker>`（如 AAPL, MSFT）|

URL 提取默认命令：无（Yahoo Finance 页面 → summarize --extract）

---

### YouTube

| 操作 | 命令 | 参数 |
|------|------|------|
| 搜索视频 | `youtube search` | `--query <str>`, `--limit N` |
| **视频转录** | `youtube transcribe` | `<url\|video_id>` (位置参数), `--lang`, `--mode raw\|grouped`, `--force-asr`, `--keep-audio` |

**URL 提取默认命令**：`youtube transcribe <url_or_video_id>`（字幕优先，Whisper large-v3 兜底）
URL 标准化：先转换为 `youtube.com/watch?v=<id>` 格式再传入
Fallback：`transcriptSource=unavailable` → summarize 无法进一步处理，报错建议用户手动下载

---

### 知乎（Zhihu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热榜 | `zhihu hot` | `--limit N` |
| 搜索 | `zhihu search` | `--keyword <str>`, `--limit N` |
| 问题详情 | `zhihu question` | `--id <question_id>`, `--limit N`（答案数）|

URL 提取默认命令：无（知乎文章/回答 URL → summarize --extract）
Fallback：summarize 失败 → cloud browser

---

## 已知视频平台域名清单（非 opencli 支持，直接报错）

用户提供以下域名的视频 URL 时，**不尝试任何提取**，直接报错说明不支持：

| 平台 | 域名 |
|------|------|
| 抖音 | `douyin.com` |
| 腾讯视频 | `v.qq.com` |
| 爱奇艺 | `iqiyi.com` |
| 优酷 | `youku.com` |
| 西瓜视频 | `xigua.com` |
| TikTok | `tiktok.com` |
| 小红书视频 | `xiaohongshu.com` / `xhslink.com`（视频笔记）|
| 微博视频 | `weibo.com`（仅 URL 含 `/video/` 或 `weibo.com/tv/` 的视频帖；普通图文帖走 summarize）|

报错模板：
> 不支持提取 [平台名] 的视频内容。建议：将视频下载到本地后，以本地文件路径重新提交，我将使用 summarize + Whisper 进行转录。

**注意**：bilibili.com 和 youtube.com/youtu.be 不在此列，由 opencli 处理。
