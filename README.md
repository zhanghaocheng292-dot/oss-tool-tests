# 开源工具实测报告

测试日期：**2026-11-06**（Asia/Shanghai，UTC+8）  
测试角色：开源软件测试工程师  
测试机器：一台无 Docker 的 Linux x86_64 云端环境（详见 [environment.md](environment.md)）  
GitHub 建议仓库名：`oss-tool-tests`（账号 `zhanghaocheng292-dot`）

> **严格区分**  
> - **实际运行成功**：本机安装后，核心功能产生了真实输出（见各 `tests/*/results/`）。  
> - **只读文档/仓库元数据**：用 GitHub API 核对了许可证、星标、最近提交/发版，**没有安装，也没有当成功推荐**。

本次没有使用任何付费 LLM 或付费 API Key。

## 结论先看

只推荐经过本机验证的 3 个项目：

1. **[Memos](https://github.com/usememos/memos) 26.11.0** — 最适合改造成 iPhone 网页工具。单文件启动，SQLite，自带 PWA（`apple-mobile-web-app-capable` + `site.webmanifest`）。已验证：创建管理员、登录、写笔记、中文标签、按内容搜索、反向搜索为空。
2. **[changedetection.io](https://github.com/dgtlmoon/changedetection.io) 0.70.2** — 适合在手机 Safari 里盯网页/价格/更新。自带 PWA 和分享接口。已验证：Web UI、REST API、抓取 `https://example.com/`、本地样例页从「价格：100 元」变为「价格：80 元」时成功检测差异。
3. **[yt-dlp](https://github.com/yt-dlp/yt-dlp) 2026.10.26** — 公开视频元数据提取能力已验证（Internet Archive、YouTube、B 站 av2）。它是命令行工具，**不能直接当 iPhone 网页 App**，需要再包一层网页或快捷指令；作为后台提取器仍然值得留着。

其余 7 个只做了资料核查，列在文末候选表，**不当作已运行成功**。

---

## 10 个候选项目

星标、最近推送时间来自 2026-11-06 23:42 CST 左右的 GitHub API。最近发版时间已换算为 Asia/Shanghai。

| 项目 | 地址 | 类别 | 许可证 | 星标 | 最近活动 | 最新发版 | 本次是否实测 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| yt-dlp | https://github.com/yt-dlp/yt-dlp | 社交媒体/公开内容提取 | Unlicense | 205707 | 推送 2026-11-04 15:16 CST | 2026.10.26（2026-10-27 06:25 CST） | **是，核心功能已跑通** |
| gallery-dl | https://github.com/mikf/gallery-dl | 社交媒体图片/画廊提取 | GPL-2.0 | 20401 | 推送 2026-10-31 19:34 CST | v1.32.19（2026-10-31 19:35 CST）；上游正在迁往 Codeberg | 否，只读文档 |
| RSSHub | https://github.com/DIYgod/RSSHub | 社交媒体转 RSS | AGPL-3.0 | 46848 | 推送 2026-11-06 22:04 CST | v2026.11.06-8596.4be79cd（2026-11-06 14:56 CST） | 否，只读文档（官方推荐 Docker，仓库体积很大） |
| Memos | https://github.com/usememos/memos | 个人知识库 / 手机网页笔记 | MIT | 64313 | 推送 2026-11-06 09:33 CST | 26.11.0（2026-11-01 22:04 CST） | **是，核心功能已跑通** |
| linkding | https://github.com/sissbruecker/linkding | 书签 / 知识管理 | MIT | 11388 | 推送 2026-10-26 12:13 CST | v1.47.0（2026-09-14 01:47 CST） | 否，只读文档（设计上依赖 Docker） |
| Karakeep | https://github.com/karakeep-app/karakeep | 稍后读 / AI 标签知识库 | AGPL-3.0 | 30360 | 推送 2026-11-04 15:57 CST | v0.34.1（2026-10-22 14:42 CST） | 否，只读文档（需要 Docker Compose：Web + Meilisearch + Chrome 等） |
| n8n | https://github.com/n8n-io/n8n | AI / 工作流自动化 | Sustainable Use License（fair-code，不是 OSI 标准开源；个人自用通常可以） | 209695 | 推送 2026-11-06 22:48 CST | stable / 2.46.6（2026-11-04 21:10 CST） | 否，只读文档（无 Docker，且内存占用较高） |
| Playwright | https://github.com/microsoft/playwright | 浏览器自动化 | Apache-2.0 | 99452 | 推送 2026-11-06 17:20 CST | v1.65.0（2026-11-06 02:25 CST） | 否，只读文档（库/测试框架，需下载浏览器） |
| changedetection.io | https://github.com/dgtlmoon/changedetection.io | 网页监控 / 工作流提醒 | Apache-2.0 | 35580 | 推送 2026-11-06 23:40 CST | 0.70.2（2026-11-06 06:55 CST） | **是，核心功能已跑通** |
| FreshRSS | https://github.com/FreshRSS/FreshRSS | 手机友好的 RSS 阅读器 | AGPL-3.0 | 16516 | 推送 2026-11-03 04:43 CST | 1.30.4（2026-10-22 04:45 CST） | 否，只读文档（需要 PHP 运行环境） |

为什么只实测这 3 个：本机没有 Docker，内存也不宽裕，且要求零付费 API。yt-dlp 用 pip 即可；Memos 有官方 Linux amd64 单文件；changedetection.io 用 pip + SQLite 即可，Web UI 也适合以后放到手机上用。

---

## 实测 1：yt-dlp 2026.10.26

- 仓库：https://github.com/yt-dlp/yt-dlp  
- 许可证：Unlicense  
- 安装：`python3 -m venv ... && pip install yt-dlp==2026.10.26`  
- 实际命令输出：`yt-dlp --version` → `2026.10.26`  
- 核心功能测试：只提取公开元数据（`--skip-download --dump-json`），不下载成片。YouTube 提取加了 `--js-runtimes node`。

### 成功

| 目标 | 结果 |
| --- | --- |
| https://archive.org/details/BigBuckBunny | 成功。extractor=`archive.org`，title=`Big Buck Bunny`，时长 596.46 秒，分辨率 1920x1080。耗时约 3.14 秒。 |
| https://www.youtube.com/watch?v=jNQXAC9IVRw （YouTube 第一个公开视频 *Me at the zoo*） | 成功。extractor=`youtube`，uploader=`jawed`，时长 19 秒，上传日期 2005-04-24，当时记录到约 4.48 亿次播放。耗时约 1.29 秒。 |
| https://www.bilibili.com/video/av2 （历史视频，BV1xx411c7mD《字幕君交流场所》） | 先失败后成功。加上从 `https://www.bilibili.com/` 拿到的**匿名** `buvid3` cookie（未登录）后提取成功：uploader=`碧诗`，时长约 2055.6 秒，上传日期 2009-09-09，播放量约 560 万。 |

精简后的 JSON 见 `tests/01-yt-dlp/results/*.metadata.json`。

### 失败（原样记录）

1. 初次用猜测的 BV `https://www.bilibili.com/video/BV1GJ411x7h7`：
   ```
   ERROR: [BiliBili] 1GJ411x7h7: Unable to download webpage: HTTP Error 412: Precondition Failed
   ```
2. 换知名公开片《后浪》`https://www.bilibili.com/video/BV1FV411d7u7`，即使带了匿名 buvid3，仍是：
   ```
   ERROR: [BiliBili] 1FV411d7u7: Unable to download webpage: HTTP Error 412: Precondition Failed
   ```
   说明：B 站并不是「装上就能提取所有公开视频」，部分 BV 会 412；但历史视频 av2 证明提取器本身可用。
3. 抖音公开视频 `https://www.douyin.com/video/7703736404513815642`：
   ```
   ERROR: [Douyin] 7703736404513815642: Fresh cookies (not necessarily logged in) are needed
   ```
   没有去复用已登录浏览器里的用户 Cookie。这是环境限制，不是提取器“装失败”。

### iPhone 适合度

**不适合直接当网页工具。** yt-dlp 是命令行程序。要在 iPhone 上用，需要另做一层：

- 自建一个很薄的网页表单（提交链接，服务器调用 yt-dlp 只返回标题/封面/简介），用 Safari 打开或加到主屏幕；或
- 用 iOS 快捷指令调用你自己的后端。

不要指望在 Safari 里直接运行它。

复现脚本：`tests/01-yt-dlp/scripts/install.sh`、`tests/01-yt-dlp/scripts/test.sh`。

---

## 实测 2：Memos 26.11.0

- 仓库：https://github.com/usememos/memos  
- 许可证：MIT  
- 安装：下载官方 `memos_26.11.0_linux_amd64.tar.gz`  
- SHA256 校验通过：`38b81c2bd1859555f4f7f277756541fd1ca332c94bbbee443626ace42d7b4061`  
- 启动：`./memos --data <dir> --port 18081 --addr 127.0.0.1 --driver sqlite`  
- 日志原文：
  ```
  Memos 26.11.0 started successfully!
  Database driver: sqlite
  Server running on 127.0.0.1:18081
  Access mode: private
  ```
- 健康检查：`GET /healthz` → `Service ready.`  
- 注意：26.x 的 REST 前缀是 `/api/...`，旧的 `/api/v1/...` 会返回 **HTTP 410**（`API v1 has been removed`）。二进制默认端口是 **8081**（Docker 镜像才是 5230）。

### 成功

| 步骤 | 结果 |
| --- | --- |
| 创建首位用户 `POST /api/users` | HTTP 200。`username=tester`，`displayName=测试员`，`role=ADMIN` |
| 登录 `POST /api/auth/signin`，请求体为 `{"passwordCredentials":{"username":"...","password":"..."}}` | HTTP 200，返回 `accessToken` |
| 写笔记 `POST /api/memos` | HTTP 200。资源名 `memos/ZAfz36Q4vZqKjWgLt6AiM9`，可见性 PRIVATE，自动抽出标签 `测试 / 开源 / 知识库`，识别到任务列表 |
| 列出笔记 `GET /api/memos` | HTTP 200，1 条 |
| 搜索 `GET /api/memos?filter=content.contains("Memos")` | HTTP 200，命中刚才那条 |
| 反向搜索 `filter=content.contains("XYZNOTFOUND12345")` | HTTP 200，`memos: []`（证明不是“无条件返回全部”） |
| 读取用户 `GET /api/users/tester` | HTTP 200 |

创建时间（UTC `2026-11-06T15:46:03Z`）换算为 **2026-11-06 23:46:03 CST**。

首页带有 PWA 所需标记：

- `<link rel="manifest" href="/site.webmanifest?v=celadon">`
- `<meta name="apple-mobile-web-app-capable" content="yes">`
- `<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">`

### 失败（已解决或记录）

1. `POST /api/auth/signin` 使用扁平 JSON `{"username":"...","password":"..."}` → **HTTP 400** `invalid credentials`。密码其实已经写入，只是 26.x 的登录字段必须包在 `passwordCredentials` 里。
2. `POST /api/v1/users` → **HTTP 410** API v1 已移除。
3. `POST /api/memos:search` → **HTTP 404**。列表过滤接口已经能搜索，不必依赖这个路径。

### iPhone 适合度

**最推荐。** 自建 Memos 后用 HTTPS 反代到公网（VPS、NAS、Cloudflare Tunnel 等），在 iPhone Safari 打开，选“添加到主屏幕”，即可当独立 App 使用。不需要付费 API。以后如果只在家里用，也可以走内网 + 按需 VPN。

复现脚本：`tests/02-memos/scripts/`。以后用 Docker 自建的样例见 `deploy/docker-compose.memos.yml`（**本环境没有 Docker，这个 compose 没有实际跑过**）。

---

## 实测 3：changedetection.io 0.70.2

- 仓库：https://github.com/dgtlmoon/changedetection.io  
- 许可证：Apache-2.0  
- 安装：`pip install changedetection.io==0.70.2`  
- `pip show` 确认 Version=0.70.2  
- 启动：`changedetection.io -h 127.0.0.1 -p 15000 -d <data> -C`  
- Web UI：`GET /` → HTTP 200，标题 `Change Detection`，有 viewport、`/site.webmanifest`、`theme-color`  
- PWA manifest：`display=standalone`，并且声明了 `share_target`（可从其它 App 把链接分享进来）  
- 系统信息 `GET /api/v1/systeminfo`（请求头 `x-api-key`）→ HTTP 200，`version: 0.70.2`

注意：数据目录里的 `secret.txt` 是 Flask 会话密钥，**不是** API key。API key 在 datastore 的 `settings.application.api_access_token`。用错会得到 HTTP 403 `Invalid access - API key invalid.`（这条失败也实际碰到了）。

### 失败（环境限制，已原样记录）

默认监控项以及后来添加的 `https://example.com/`，在未设置环境变量时全部报：

```
Exception: Fetch blocked: 'https://example.com/' resolves to a private/reserved IP address
or contains a parser-differential payload. Set ALLOW_IANA_RESTRICTED_ADDRESSES=true to allow.
```

同样的错误也出现在：

- `https://news.ycombinator.com/`
- `https://changedetection.io/CHANGELOG.txt`

这是软件自带的 SSRF 防护。本云端环境的出口代理会把公网域名解析成内网地址，所以必须按报错提示设置 `ALLOW_IANA_RESTRICTED_ADDRESSES=true` 才能继续测。**普通家用电脑或 VPS 通常不需要打开它**；打开后等于允许抓取解析到内网的地址，只应在信任的环境里用于排错。

### 成功（设置该变量并重启之后）

| 步骤 | 时间 (CST) | 结果 |
| --- | --- | --- |
| 重新检查 `https://example.com/` | 2026-11-06 23:47:09 | `last_error=false`，快照 MD5 `718d0cac5fba85218b5b1791bde6114e`。抽出的文本含 “This domain is for use in documentation examples...” |
| 添加并检查本地样例 `http://127.0.0.1:18099/sample.html`（价格：100 元） | 2026-11-06 23:47:10 | `last_error=false`，MD5 `56e03c43adba0d347d03ed9ab8ac6469`。快照原文见 `tests/03-changedetection/results/fixture_snapshot_v1.txt` |
| 把页面改成「价格：80 元」后再检查 | 2026-11-06 23:47:18 | **检测到变化**：`last_changed=1793980038`，新 MD5 `ea928d63be341b53a460f0bc31f21834`。历史里出现两个时间戳。v2 快照见 `fixture_snapshot_v2.txt` |

关键 API（均已跑通）：

- `POST /api/v1/watch` → HTTP 201 `{"uuid":"..."}`
- `GET /api/v1/watch/{uuid}?recheck=1` → HTTP 200 `"OK"`
- `GET /api/v1/watch/{uuid}/history` → `{unix_ts: snapshot_path}`
- `GET /api/v1/watch/{uuid}/history/{ts}` → 纯文本快照

`GET /api/v1/watch/{uuid}/recheck` 返回 **HTTP 404**（正确的重检查路径是带查询参数 `?recheck=1`）。

### iPhone 适合度

**适合作为网页工具。** 界面已做移动适配并提供 PWA。自建后用 HTTPS 反代，建议在设置里打开应用密码，然后用 Safari「添加到主屏幕」。可以盯商品页、商店活动页、GitHub Release 页面等，不需要付费 API。动态渲染很重的页面以后可以再加 Playwright/Chrome 抓取（本次未测浏览器抓取后端）。

复现脚本：`tests/03-changedetection/scripts/`。Docker 样例见 `deploy/docker-compose.changedetection.yml`（**本环境没有跑过 Docker**）。

---

## 未实测的 7 个候选（只读文档）

这些项目看起来都还在积极维护，但**本次没有安装，也没有运行核心功能**：

- **gallery-dl**：和 yt-dlp 同类的提取器，偏向图片站。本机可以 pip 安装，但 3 个实测名额留给了覆盖不同类别的项目。最新维护已部分迁到 Codeberg。
- **RSSHub**：把微博、B 站、Telegram 等公开动态转成 RSS，和 FreshRSS 搭配会很有用。官方主路径是 Docker；源码仓库很大，本机无 Docker，故未部署。
- **linkding**：轻量书签服务，手机浏览器友好，设计上就是 Docker 部署。
- **Karakeep**：书签 + 全文搜索 + 可选 AI 自动标签，有移动端相关能力，但依赖多容器（Web、Meilisearch、Chrome 等），本机不具备。
- **n8n**：可视化自动化很强，也能接本地模型；许可证是 Sustainable Use License（个人自用一般可以，但不是标准开源）。无 Docker 且内存需求高，未装。
- **Playwright**：浏览器自动化标准库，适合以后给自己写脚本或给 changedetection 做 JS 渲染，但本身不是面向小白的成品网页 App。
- **FreshRSS**：非常适合 iPhone 看 RSS 的自建阅读器，需要 PHP。没有 Docker/PHP-FPM 栈，未装。

---

## 以后在 iPhone 上怎么用（仅针对已验证项目）

1. **Memos（优先）**  
   在有公网或内网穿透的机器上用 Docker 或二进制启动 → HTTPS → Safari 打开 → 添加到主屏幕。日常用来记想法、清单、标签检索。
2. **changedetection.io**  
   同样自建 + HTTPS + 应用密码 + Safari 主屏幕。把想盯的商品页、活动页、开源项目 Release 页加进去。
3. **yt-dlp**  
   留在服务器当后台工具。如果以后需要“手机里贴一条公开视频链接就看到标题和简介”，再单独包一个小网页（本次没有做这个外壳）。

本云端测试机不是长期公网服务，测试用的本地服务也没有暴露到互联网。要在手机上真正用起来，需要你自己的 NAS、家里电脑或一台 VPS。

---

## 如何复现

```bash
# 1) yt-dlp
tests/01-yt-dlp/scripts/install.sh
tests/01-yt-dlp/scripts/test.sh

# 2) Memos
tests/02-memos/scripts/install.sh
tests/02-memos/scripts/start.sh
tests/02-memos/scripts/test.sh

# 3) changedetection.io
tests/03-changedetection/scripts/install.sh
tests/03-changedetection/scripts/start.sh
tests/03-changedetection/scripts/test.sh
```

脚本默认把虚拟环境和二进制装到 `/tmp/oss-tools/`，避免把上百 MB 的运行时提交进 Git。

---

## 推送到 GitHub

本目录是完整可提交内容。建议在 GitHub 上建一个空仓库 `oss-tool-tests`（不要勾选 README / .gitignore / License），再把这里的文件推上去。不要提交 `tests/*/data/` 运行时数据，那里可能含密码哈希和 API token（已写入 `.gitignore`）。
