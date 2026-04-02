---
title: "content-access skill 合约一致性与路由规范收敛"
date: 2026-04-02
category: developer-experience
module: content-access
problem_type: developer_experience
component: tooling
severity: medium
applies_when:
  - 维护 AI agent 消费的 skill / prompt / 规则文档
  - 规则文档跨越多个文件且多处定义同一概念
  - 有"一般规则 + 例外"结构的合同型文档
  - 路由/决策系统中存在降级行为
tags:
  - skill-authoring
  - routing-layer
  - contract-consistency
  - naming-convention
  - exception-management
  - content-access
---

# content-access skill 合约一致性与路由规范收敛

## Context

content-access 是一个三层路由 skill（opencli → summarize → cloud_browser），AI agent 依据 SKILL.md 和 references/ 中的规则做路由决策。在功能基本完成后，发现文档自身成为不一致性的来源：命名混用、规则自相矛盾、硬编码阈值误判、降级语义被静默改变。这些不是功能缺陷，而是**合同模糊性**——AI agent 读到矛盾规则时无法像人类一样凭经验判断意图，会产生不可预测的行为。

整个修复横跨 3 轮对话，未添加任何新功能，只做规则收紧。

## Guidance

### 1. 命名统一：选一种形式，贯穿到底

技术标识符（路由字段值、脚本文件名、代码引用）必须使用同一形式。

| 位置 | 修复前 | 修复后 |
|------|--------|--------|
| routing-rules route 字段 | `cloud browser` | `cloud_browser` |
| SKILL.md 描述 | `cloud browser` | `cloud_browser` |
| output-schema | `cloud browser` | `cloud_browser` |
| 脚本注释 | `cloud browser` | `cloud_browser` |

做法：以程序性标识符为准（下划线形式），全局 grep 替换，包括注释。

### 2. 规则自洽：例外必须在合同中显式声明

主规则说"禁止跳级"，但微信和 Reddit 文档中写的是直接走 Tier 3。规则在语义上是对的，但形式上自相矛盾。

做法：**主合同 + 例外合同分离。** 创建 `references/exceptions.md`，包含：

- `allowed_direct_tier3` — 允许跳过 Tier 2 直接进入 Tier 3 的域名白名单
- `unsupported_video_extraction` — 不支持视频提取（非整站）的平台列表
- `disambiguation` — 易混淆能力消歧（如 `weixin download` 是附件下载，不是正文提取）

主规则改为："禁止跳级——例外见 `exceptions.md` 白名单。"

### 3. 失败判断：语义标准优于数值阈值

"内容 < 200 字符视为失败"对短公告、摘要页产生假阳性，触发不必要的降级。

修复后的 Tier 2 失败判断：

| 失败类型 | 判断依据 | → fallback_reason |
|---------|---------|-------------------|
| 空内容 | 返回空字符串或纯空白 | `summarize_failed` |
| 错误页 | 包含 error/403/captcha 等 | `summarize_failed` |
| 关键字段缺失 | 无法提取 title 和 content | `summarize_failed` |
| 内容残缺 | 有内容但明显截断 | `content_incomplete` |

关键原则：**短内容不算失败。不要用字符数阈值判断。**

### 4. 降级路由：按请求类型分叉

不同类型请求的降级语义不同：

| 请求类型 | 修复前 | 修复后 |
|----------|--------|--------|
| read 型（URL 提取） | opencli 失败 → 降级 Tier 2 | 保留（语义一致） |
| structured browse（search/hot/feed） | opencli 失败 → 降级 Tier 2 | **报错，不降级**（Tier 2 无法提供结构化结果） |

此规则同时适用于"命令不存在"和"其他未知错误"两种情况。

### 5. 平台限制：限制范围必须精确到操作粒度

"unsupported_platforms"暗示整站不可用，但只有视频提取不支持。改为 `unsupported_video_extraction`，每个平台标注"不受影响的操作"：

| 平台 | 触发条件 | 不受影响 |
|------|---------|---------|
| TikTok | 视频 URL | `tiktok explore/search/profile` 正常 Tier 1 |
| 小红书 | 视频笔记 | 图文笔记 Tier 2；`xiaohongshu feed/search` Tier 1 |
| 微博 | `/video/` 或 `/tv/` | 图文微博 Tier 2；`weibo hot/search` Tier 1 |

### 6. 输出 Schema：必须包含可审计字段

新增两个必填字段：

- `intent` — 用户原始意图的一句话归纳
- `provider_command` — 实际执行的命令（含参数）

这样事后可以回答："为什么走了这条路径？为什么没走其他路径？"

### 7. 文档去重：规则定义一次，其他地方引用

README 重复 SKILL.md 的规则是漂移温床。修复后 README 只负责"这是什么、如何安装"，规则全部在 SKILL.md + references/ 中定义一次。

### 8. 验收场景：为路由合同写可验证用例

创建 `references/routing-acceptance.md`，8 个场景：

1. 微信文章 → Tier 3（白名单例外）
2. Reddit URL 正文 → Tier 3（白名单例外）
3. 普通博客 → Tier 2（主合同）
4. X 线程 → Tier 1（capability-matrix）
5. 本地 PDF → Tier 2
6. 短公告页 → Tier 2 成功（不因短而误判失败）
7. TikTok 视频 → 报错（unsupported_video_extraction）
8. 小红书视频笔记 → 报错（unsupported_video_extraction）

每个场景要求能解释"为什么走这条路径，为什么不走其他路径"。

## Why This Matters

AI agent 消费 skill 文档的方式与人类不同：人类读到矛盾规则会凭经验判断意图，agent 会随机选择或产生不确定行为。文档模糊性在 AI 系统中的代价高于人类协作。

具体风险：
- 命名不统一 → agent 生成错误的 route 字段值
- 规则自洽性破坏 → agent 行为不可预测
- 数值阈值 → 合法短页面被错误降级
- 统一降级 → structured browse 请求静默返回错误语义的数据

## When to Apply

- 维护 AI agent 消费的 skill、prompt、或多文件规则集时
- 有"一般规则 + 例外"结构的文档
- 路由/决策系统的失败判断使用了数值阈值
- 系统存在降级行为但未按请求类型区分语义
- 多个文件定义"同一件事"产生漂移风险时

## Examples

### 例外合同分离（前后对比）

**修复前：** 主规则和例外散落在 3 个文件中

```
SKILL.md:        "严格顺序，禁止跳级"
routing-rules:   "Reddit → 直接 Tier 3"
fallback-matrix: "微信 → 直接 Tier 3"
```

**修复后：** 主规则引用例外合同

```
SKILL.md:        "严格顺序，禁止跳级——例外见 exceptions.md"
exceptions.md:   allowed_direct_tier3 白名单（微信、Reddit）
                 unsupported_video_extraction（8 个平台）
                 disambiguation（weixin download ≠ 正文提取）
```

### 降级分叉（错误处理表）

**修复前：**

| 错误 | 处理 |
|------|------|
| command not found | 降级 Tier 2 |
| 其他未知错误 | 降级 Tier 2 |

**修复后：**

| 错误 | 读取型请求 | 结构化浏览请求 |
|------|-----------|--------------|
| command not found | 降级 Tier 2 | 报错，不降级 |
| 其他未知错误 | 降级 Tier 2 | 报错，不降级 |

## Related

- [content-access skill 构建经验](content-access-skill-build.md) — 同一 skill 的首次构建阶段文档（部署、脚本健壮性、API key 管理）
