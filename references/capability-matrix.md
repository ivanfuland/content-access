# Content Access Capability Matrix

opencli 版本参考：**最新版（运行 `opencli list` 查看实时注册表）**

## 速查

**URL 提取支持 opencli 的平台：**
- YouTube → `youtube transcript <video_id>`（原生）或 `youtube transcribe <url>`（plugin，优先）
- Bilibili → `bilibili transcribe <url>`（plugin，优先）| 无字幕时 `bilibili subtitle <bvid>`（原生备用）
- Twitter/X → `twitter thread <tweet-id>`
- V2EX → `v2ex topic --id <id>`
- Reddit → cloud browser（封锁裸 HTTP）
- web → `web read --url <url>`（通用网页读取，需登录态）

**YouTube/Bilibili 说明：** 转录功能由 `opencli-plugin-transcribe`（已预装）提供，非原生 adapter 命令。原生 YouTube 有 `transcript` 命令，原生 Bilibili 有 `subtitle` 命令。

**已知不支持视频提取的平台（直接报错）：**
douyin.com · v.qq.com · iqiyi.com · youku.com · xigua.com · tiktok.com · weibo.com(视频帖)

**直接走 cloud browser 的平台：**
mp.weixin.qq.com · reddit.com（封锁 HTTP）

---

## 平台能力矩阵

### 浏览器 Adapter（需登录态，Browser CDP）

---

#### Twitter / X

| 操作 | 命令 | 参数 |
|------|------|------|
| 时间线 | `twitter timeline` | `--limit N` |
| 热门话题 | `twitter trending` | `--limit N` |
| 搜索 | `twitter search` | `--query <str>`, `--limit N` |
| 书签 | `twitter bookmarks` | `--limit N` |
| 通知 | `twitter notifications` | `--limit N` |
| 关注列表 | `twitter following` | `--user <handle>`, `--limit N` |
| 粉丝列表 | `twitter followers` | `--user <handle>`, `--limit N` |
| 用户推文 | `twitter profile` | `--username <handle>`, `--limit N` |
| 单推文/线程 | `twitter thread` | `<tweet-id>` |
| 文章 | `twitter article` | — |
| 发推 ⚠️ | `twitter post` | `--text <str>` |
| 回复 ⚠️ | `twitter reply` | `--url <tweet_url>`, `--text <str>` |
| 点赞 ⚠️ | `twitter like` | `--url <tweet_url>` |
| 删推 ⚠️ | `twitter delete` | `--url <tweet_url>` |
| 关注 ⚠️ | `twitter follow` | — |
| 取关 ⚠️ | `twitter unfollow` | — |
| 书签保存 ⚠️ | `twitter bookmark` | — |
| 私信回复 ⚠️ | `twitter reply-dm` | — |

**URL 提取**：`twitter thread <tweet-id>`（从 `x.com/<user>/status/<id>` 取末段）
Fallback：失败 → summarize --extract

---

#### Bilibili（B站）

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
| 用户投稿 | `bilibili user-videos` | `--uid <id>`, `--limit N` |
| 字幕（原生） | `bilibili subtitle` | `<bvid>` |
| 视频转录（plugin） | `bilibili transcribe` | `<url\|bvid>`（需 opencli-plugin-transcribe）|

**URL 提取默认命令**：`bilibili transcribe <url_or_bvid>`（plugin 提供，字幕优先，Whisper 兜底）
Fallback：plugin 失败 → summarize --extract

---

#### YouTube

| 操作 | 命令 | 参数 |
|------|------|------|
| 搜索视频 | `youtube search` | `--query <str>`, `--limit N` |
| 视频详情 | `youtube video` | — |
| 字幕（原生） | `youtube transcript` | `<video_id>` |
| 视频转录（plugin） | `youtube transcribe` | `<url\|video_id>`（需 opencli-plugin-transcribe）|

**URL 提取默认命令**：`youtube transcribe <url_or_video_id>`（plugin 优先）；plugin 不可用时 → `youtube transcript <video_id>`
URL 标准化：先转为 `youtube.com/watch?v=<id>` 再传入
Fallback：
- `transcriptSource=unavailable` → 直接报错，不降级
- 其他失败 → summarize --extract

---

#### Reddit

| 操作 | 命令 | 参数 |
|------|------|------|
| 首页 | `reddit frontpage` | `--limit N` |
| 热门帖子 | `reddit hot` | `--subreddit`, `--limit N` |
| 热门 | `reddit popular` | `--limit N` |
| 搜索 | `reddit search` | `--query <str>`, `--limit N` |
| 指定 subreddit | `reddit subreddit` | `--name <sub>`, `--sort hot\|new\|top\|rising`, `--limit N` |
| 帖子详情 | `reddit read` | — |
| 用户 | `reddit user` | — |
| 用户帖子 | `reddit user-posts` | — |
| 用户评论 | `reddit user-comments` | — |
| 点赞 ⚠️ | `reddit upvote` | — |
| 保存 ⚠️ | `reddit save` | — |
| 评论 ⚠️ | `reddit comment` | — |
| 订阅 ⚠️ | `reddit subscribe` | — |

**URL 提取**：封锁裸 HTTP → 直接走 cloud browser（跳过 summarize）

---

#### 知乎（Zhihu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热榜 | `zhihu hot` | `--limit N` |
| 搜索 | `zhihu search` | `--keyword <str>`, `--limit N` |
| 问题详情 | `zhihu question` | `--id <question_id>`, `--limit N` |
| 下载 ⚠️ | `zhihu download` | — |

URL 提取：无（知乎文章/回答 URL → summarize --extract → cloud browser）

---

#### 微博（Weibo）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热搜榜 | `weibo hot` | `--limit N` |
| 搜索 | `weibo search` | `--query <str>`, `--limit N` |

URL 提取：无（普通图文帖 → summarize；视频帖 `/video/` 或 `weibo.com/tv/` → 报错不支持）

---

#### 小红书（Xiaohongshu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 首页推荐 | `xiaohongshu feed` | `--limit N` |
| 搜索笔记 | `xiaohongshu search` | `--keyword <str>`, `--limit N` |
| 通知 | `xiaohongshu notifications` | `--type mentions\|likes\|connections`, `--limit N` |
| 用户笔记 | `xiaohongshu user` | `--id <user_id>`, `--limit N` |
| 下载 ⚠️ | `xiaohongshu download` | — |
| 发布 ⚠️ | `xiaohongshu publish` | — |
| 创作者笔记 ⚠️ | `xiaohongshu creator-notes` | — |

URL 提取：无（图文笔记 → summarize；视频笔记 → 报错不支持）

---

#### 雪球（Xueqiu）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门动态 | `xueqiu hot` | `--limit N` |
| 热门股票 | `xueqiu hot-stock` | `--limit N`, `--type 10\|12` |
| 关注动态 | `xueqiu feed` | `--page N`, `--limit N` |
| 搜索 | `xueqiu search` | `--query <str>`, `--limit N` |
| 股票行情 | `xueqiu stock` | `--symbol <code>`（如 SH600519, AAPL）|
| 评论 | `xueqiu comments` | — |
| 自选股 | `xueqiu watchlist` | `--category 1\|2\|3`, `--limit N` |
| 财报日期 | `xueqiu earnings-date` | — |
| 基金持仓 | `xueqiu fund-holdings` | — |
| 基金快照 | `xueqiu fund-snapshot` | — |

URL 提取：无（雪球帖子 → summarize）

---

#### BOSS直聘

| 操作 | 命令 | 参数 |
|------|------|------|
| 职位搜索 | `boss search` | `--query <str>`, `--city`, `--experience`, `--degree`, `--salary`, `--page N`, `--limit N` |
| 职位详情 | `boss detail` | — |
| 推荐职位 | `boss recommend` | — |
| 我的职位列表 | `boss joblist` | — |
| 打招呼 ⚠️ | `boss greet` | — |
| 批量打招呼 ⚠️ | `boss batchgreet` | — |
| 发消息 ⚠️ | `boss send` | — |
| 聊天列表 | `boss chatlist` | — |
| 聊天消息 | `boss chatmsg` | — |
| 邀请面试 ⚠️ | `boss invite` | — |
| 简历 | `boss resume` | — |
| 统计 | `boss stats` | — |

URL 提取：无（职位详情 URL → summarize --extract）

---

#### V2EX

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门话题 | `v2ex hot` | `--limit N` |
| 最新话题 | `v2ex latest` | `--limit N` |
| 主题详情 | `v2ex topic` | `--id <topic_id>` |
| 节点 | `v2ex node` | — |
| 用户资料 | `v2ex user` | — |
| 用户回复 | `v2ex replies` | — |
| 节点列表 | `v2ex nodes` | — |
| 个人资料 | `v2ex me` | — |
| 每日签到 ⚠️ | `v2ex daily` | — |
| 通知 | `v2ex notifications` | `--limit N` |

**URL 提取**：`v2ex topic --id <topic_id>`（从 URL `/t/<id>` 提取 id）
Fallback：summarize --extract

---

#### LinkedIn

| 操作 | 命令 | 参数 |
|------|------|------|
| 时间线 | `linkedin timeline` | — |
| 搜索 | `linkedin search` | — |

URL 提取：无（LinkedIn 文章 → summarize）

---

#### 抖音百度贴吧（Tieba）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门 | `tieba hot` | — |
| 帖子 | `tieba posts` | — |
| 搜索 | `tieba search` | — |
| 阅读 | `tieba read` | — |

---

#### Instagram

| 操作 | 命令 | 参数 |
|------|------|------|
| 探索 | `instagram explore` | — |
| 搜索 | `instagram search` | — |
| 用户资料 | `instagram profile` | — |
| 用户信息 | `instagram user` | — |
| 粉丝/关注 | `instagram followers` / `following` | — |
| 关注/取关 ⚠️ | `instagram follow` / `unfollow` | — |
| 点赞/取消 ⚠️ | `instagram like` / `unlike` | — |
| 评论 ⚠️ | `instagram comment` | — |
| 收藏 ⚠️ | `instagram save` / `unsave` | — |
| 已保存 | `instagram saved` | — |

---

#### TikTok

| 操作 | 命令 | 参数 |
|------|------|------|
| 探索 | `tiktok explore` | — |
| 搜索 | `tiktok search` | — |
| 用户资料 | `tiktok profile` | — |
| 点赞/取消 ⚠️ | `tiktok like` / `unlike` | — |
| 关注/取关 ⚠️ | `tiktok follow` / `unfollow` | — |

⚠️ TikTok 视频内容提取不支持（见不支持清单）

---

#### Facebook

| 操作 | 命令 | 参数 |
|------|------|------|
| 动态 | `facebook feed` | — |
| 搜索 | `facebook search` | — |
| 个人资料 | `facebook profile` | — |
| 好友/群组/活动 | `facebook friends` / `groups` / `events` | — |
| 通知/记忆 | `facebook notifications` / `memories` | — |
| 加好友/加群 ⚠️ | `facebook add-friend` / `join-group` | — |

---

#### Medium

| 操作 | 命令 | 参数 |
|------|------|------|
| 推荐 | `medium feed` | — |
| 搜索 | `medium search` | — |
| 用户 | `medium user` | — |

URL 提取：无（Medium 文章 → summarize --extract）

---

#### Substack

| 操作 | 命令 | 参数 |
|------|------|------|
| 推荐 | `substack feed` | — |
| 搜索 | `substack search` | — |
| 出版物 | `substack publication` | — |

URL 提取：无（Substack 文章 → summarize --extract）

---

#### Pixiv

| 操作 | 命令 | 参数 |
|------|------|------|
| 排行榜 | `pixiv ranking` | — |
| 搜索 | `pixiv search` | — |
| 用户 | `pixiv user` | — |
| 作品 | `pixiv illusts` | — |
| 详情 | `pixiv detail` | — |
| 下载 ⚠️ | `pixiv download` | — |

---

#### 豆瓣（Douban）

| 操作 | 命令 | 参数 |
|------|------|------|
| 搜索 | `douban search` | — |
| Top250 | `douban top250` | — |
| 条目 | `douban subject` | — |
| 图片 | `douban photos` | — |
| 下载 ⚠️ | `douban download` | — |
| 电影热映 | `douban movie-hot` | — |
| 图书热销 | `douban book-hot` | — |

---

#### 微信读书（Weread）

| 操作 | 命令 | 参数 |
|------|------|------|
| 书架 | `weread shelf` | — |
| 搜索 | `weread search` | — |
| 书籍 | `weread book` | — |
| 排行榜 | `weread ranking` | — |
| 读书笔记 | `weread notebooks` | — |
| 划线 | `weread highlights` | — |
| 笔记 | `weread notes` | — |

---

#### Jike（即刻）

| 操作 | 命令 | 参数 |
|------|------|------|
| 动态 | `jike feed` | — |
| 搜索 | `jike search` | — |
| 圈子 | `jike topic` | — |
| 用户 | `jike user` | — |
| 通知 | `jike notifications` | — |
| 发帖 ⚠️ | `jike create` | — |
| 评论/点赞/转发 ⚠️ | `jike comment` / `like` / `repost` | — |

---

#### Bloomberg

| 操作 | 命令 | 参数 |
|------|------|------|
| 主页/市场/科技/商业等 | `bloomberg main` / `markets` / `tech` / `politics` / `businessweek` / `opinions` / `economics` / `industries` / `feeds` / `news` | — |

URL 提取：无（Bloomberg 文章 → summarize --extract）

---

#### 36kr

| 操作 | 命令 | 参数 |
|------|------|------|
| 新闻 | `36kr news` | — |
| 热点 | `36kr hot` | — |
| 搜索 | `36kr search` | — |
| 文章详情 | `36kr article` | — |

URL 提取：`36kr article <url>`（如支持）；否则 → summarize --extract

---

#### 新浪博客（Sinablog）

| 操作 | 命令 | 参数 |
|------|------|------|
| 热门 | `sinablog hot` | — |
| 搜索 | `sinablog search` | — |
| 文章 | `sinablog article` | — |
| 用户 | `sinablog user` | — |

---

#### Google

| 操作 | 命令 | 参数 |
|------|------|------|
| 新闻 | `google news` | — |
| 搜索 | `google search` | `--query <str>` |
| 联想 | `google suggest` | — |
| 趋势 | `google trends` | — |

---

#### 微信文章（Weixin）

| 操作 | 命令 | 参数 |
|------|------|------|
| 下载 | `weixin download` | — |

**URL 提取**：mp.weixin.qq.com → 直接 cloud browser（--wechat 模式，跳过 summarize）

---

#### 其他浏览器 Adapter（命令列表）

| Adapter | 主要命令 |
|---------|---------|
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
| `notebooklm` | `status`, `list`, `open`, `select`, `get`, `metadata`, `source-list`, `source-get`, `source-fulltext`, `source-guide`, `history`, `note-list`, `notes-get`, `summary` |
| `doubao` | `status`, `new`, `send`, `read`, `ask`, `history`, `detail`, `meeting-summary`, `meeting-transcript` |
| `producthunt` | `posts`, `today`, `hot`, `browse` |
| `ones` | `login`, `me`, `token-info`, `tasks`, `my-tasks`, `task`, `worklog`, `logout` |
| `jd` | `item` |
| `amazon` | `bestsellers`, `search`, `product`, `offer`, `discussion` |
| `imdb` | `search`, `title`, `top`, `trending`, `person`, `reviews` |
| `web` | `read --url <url>`（通用网页，需登录态） |

---

### 公共 API Adapter（无需登录）

| Adapter | 主要命令 |
|---------|---------|
| `hackernews` | `top`, `new`, `best`, `ask`, `show`, `jobs`, `search`, `user` |
| `bbc` | `news` |
| `devto` | `top`, `tag`, `user` |
| `dictionary` | `search`, `synonyms`, `examples` |
| `apple-podcasts` | `search`, `episodes`, `top` |
| `xiaoyuzhou` | `podcast`, `podcast-episodes`, `episode` |
| `yahoo-finance` | `quote --symbol <ticker>` |
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

---

### 桌面 Adapter（CDP 控制本地 App）

| Adapter | 主要命令 |
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

## 已知视频平台域名清单（非 opencli 支持，直接报错）

用户提供以下域名的视频 URL 时，**不尝试任何提取**，直接报错：

| 平台 | 域名 |
|------|------|
| 抖音 | `douyin.com` |
| 腾讯视频 | `v.qq.com` |
| 爱奇艺 | `iqiyi.com` |
| 优酷 | `youku.com` |
| 西瓜视频 | `xigua.com` |
| TikTok | `tiktok.com`（视频内容）|
| 小红书视频 | `xiaohongshu.com` / `xhslink.com`（视频笔记）|
| 微博视频 | `weibo.com`（URL 含 `/video/` 或 `weibo.com/tv/`；普通图文帖走 summarize）|

报错模板：
> 不支持提取 [平台名] 的视频内容。建议：将视频下载到本地后，以本地文件路径重新提交，我将使用 summarize + Whisper 进行转录。

**注意**：bilibili.com 和 youtube.com/youtu.be 由 opencli-plugin-transcribe 处理，不在此列。
