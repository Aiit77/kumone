# Changelog

每个版本必须在此记录变更；发布流程会提取对应版本的段落，作为 GitHub Release
正文并渲染进 Sparkle appcast 的更新说明。Release notes are bilingual: each
version section contains an `### English` part followed by a `### 简体中文`
part. 段落格式：`## <版本号> - <日期>`。

## 0.1.5 - 2026-08-16

### English

- Added: Radar Playlists section on Home (Personal Radar / Chinese / Western / Japanese — personalized per account)
- Added: English localization; the app follows the system language
- Fixed: Cloud Disk always showed "no songs" — the real API nests song data under `privateCloud`/`simpleSong` and serves numeric quota fields, which broke decoding

### 简体中文

- 新增：首页「雷达歌单」专区（私人雷达 / 华语 / 欧美 / 日系，按账号个性化生成）
- 新增：英文界面，App 跟随系统语言
- 修复：音乐云盘始终显示「没有歌曲」的问题（真实接口把歌曲数据嵌在 `privateCloud`/`simpleSong` 里、容量字段为数字，导致解码失败）

## 0.1.4 - 2026-08-16

### English

- Fixed: new accounts (or accounts with little listening history) got a raw decoding error on the Daily Recommendations page because the API returns `data: null`; related endpoints (Personal FM, Heartbeat Mode, Cloud Disk) hardened the same way
- Improved: Daily Recommendations now shows a friendly empty state, and decoding errors no longer surface raw error details to the user

### 简体中文

- 修复：新账号或听歌历史不足时，每日推荐接口返回空数据（`data: null`）导致页面报「数据解析失败」的问题；相关接口（私人漫游、心动模式、云盘）同步加固
- 改进：每日推荐无数据时显示友好的空状态提示；解析错误不再向用户展示原始错误详情

## 0.1.3 - 2026-08-16

### English

- Fixed: "Play All" on a playlist failed silently (and the player bar never appeared) when every track was gray; it now matches the track list behavior and keeps gray tracks when unblocking is enabled (#1)
- Improved: the player bar is now always visible with a placeholder idle state, removing the first-play layout jump (#1)

### 简体中文

- 修复：歌单「播放全部」在整单灰色歌曲时静默失败、播放条不出现的问题（现在与列表行为一致，解锁开启时保留灰色歌曲）（#1）
- 改进：播放条改为常驻：未播放时显示占位状态，消除首次播放时的布局跳动，也不再遮挡列表底部（#1）

## 0.1.2 - 2026-08-16

### English

- Improved: the window toolbar (sidebar toggle, page title, search field) is hidden while the immersive now-playing page is open
- Improved: tightened the sidebar's leading insets for a more compact navigation and playlist list

### 简体中文

- 改进：沉浸播放页打开时隐藏窗口工具栏（侧边栏折叠按钮、页面标题与搜索框不再露出）
- 改进：收紧侧边栏行的左侧留白，导航与歌单列表更紧凑

## 0.1.1 - 2026-08-16

### English

- Fixed: switching back to Home from other pages jittered the sidebar and flashed skeletons (Home and Explore page state is now kept across sidebar switches, no reloading)

### 简体中文

- 修复：从每日推荐等页面切回推荐时，侧边栏抖动、首页闪骨架屏的问题（首页与精选的页面状态现在跨切换保留，不再重复加载）

## 0.1.0 - 2026-08-16

### English

- First public release
- QR code login with locally persisted, auto-refreshed cookies
- Home: daily recommendations, Personal FM, Heartbeat Mode, recommended playlists, charts, new albums, recommended artists
- Explore: category playlists with infinite scrolling
- Playback: Standard to Hi-Res quality, shuffle / repeat, play queue, gray track detection with third-party source unblocking
- Immersive now-playing page: artwork-tinted gradient backdrop with large synced lyrics
- Library: liked songs, playlists, albums, artists, recently played, cloud disk
- Search: aggregate / songs / artists / albums / playlists
- System integration: media keys, Control Center Now Playing, scrobbling
- Built-in Sparkle automatic updates

### 简体中文

- 首个公开版本
- 扫码登录，Cookie 本地持久化、自动续期
- 推荐页：每日推荐、私人漫游、心动模式、推荐歌单、排行榜、新碟上架、推荐歌手
- 精选页：分类歌单无限滚动
- 播放：标准 ~ Hi-Res 音质、随机 / 循环、播放队列、灰色歌曲识别与第三方音源解锁
- 沉浸播放页：封面取色渐变背景、大字同步歌词
- 音乐库：喜欢的音乐、歌单、专辑、歌手、最近播放、音乐云盘
- 搜索：综合 / 单曲 / 歌手 / 专辑 / 歌单
- 系统集成：媒体键、控制中心 Now Playing、听歌打卡
- 内置 Sparkle 自动更新
