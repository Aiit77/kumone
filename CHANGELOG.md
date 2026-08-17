# Changelog

每个版本必须在此记录变更；发布流程会提取对应版本的段落，作为 GitHub Release
正文并渲染进 Sparkle appcast 的更新说明。Sections are the change categories
(`### Added / 新增`, `### Fixed / 修复`, `### Improved / 改进`); within each
section the English bullets come first, followed by their Simplified Chinese
counterparts. 段落格式：`## <版本号> - <日期>`，条目必须写成单行。

## 0.1.6 - 2026-08-16

### Improved / 改进

- The "+" button next to Created Playlists now anchors to the trailing edge aligned with the playlist rows, independent of header text length in any language
- 「创建的歌单」的加号按钮改为尾部锚定并与歌单行右缘对齐，位置不再受各语言标题长度影响

## 0.1.5 - 2026-08-16

### Added / 新增

- Radar Playlists section on Home (Personal Radar / Chinese / Western / Japanese — personalized per account)
- English localization; the app follows the system language
- 首页「雷达歌单」专区（私人雷达 / 华语 / 欧美 / 日系，按账号个性化生成）
- 英文界面，App 跟随系统语言

### Fixed / 修复

- Cloud Disk always showed "no songs" — the real API nests song data under `privateCloud`/`simpleSong` and serves numeric quota fields, which broke decoding
- 音乐云盘始终显示「没有歌曲」的问题（真实接口把歌曲数据嵌在 `privateCloud`/`simpleSong` 里、容量字段为数字，导致解码失败）

## 0.1.4 - 2026-08-16

### Fixed / 修复

- New accounts (or accounts with little listening history) got a raw decoding error on the Daily Recommendations page because the API returns `data: null`; related endpoints (Personal FM, Heartbeat Mode, Cloud Disk) hardened the same way
- 新账号或听歌历史不足时，每日推荐接口返回空数据（`data: null`）导致页面报「数据解析失败」的问题；相关接口（私人漫游、心动模式、云盘）同步加固

### Improved / 改进

- Daily Recommendations now shows a friendly empty state, and decoding errors no longer surface raw error details to the user
- 每日推荐无数据时显示友好的空状态提示；解析错误不再向用户展示原始错误详情

## 0.1.3 - 2026-08-16

### Fixed / 修复

- "Play All" on a playlist failed silently (and the player bar never appeared) when every track was gray; it now matches the track list behavior and keeps gray tracks when unblocking is enabled (#1)
- 歌单「播放全部」在整单灰色歌曲时静默失败、播放条不出现的问题（现在与列表行为一致，解锁开启时保留灰色歌曲）（#1）

### Improved / 改进

- The player bar is now always visible with a placeholder idle state, removing the first-play layout jump (#1)
- 播放条改为常驻：未播放时显示占位状态，消除首次播放时的布局跳动，也不再遮挡列表底部（#1）

## 0.1.2 - 2026-08-16

### Improved / 改进

- The window toolbar (sidebar toggle, page title, search field) is hidden while the immersive now-playing page is open
- Tightened the sidebar's leading insets for a more compact navigation and playlist list
- 沉浸播放页打开时隐藏窗口工具栏（侧边栏折叠按钮、页面标题与搜索框不再露出）
- 收紧侧边栏行的左侧留白，导航与歌单列表更紧凑

## 0.1.1 - 2026-08-16

### Fixed / 修复

- Switching back to Home from other pages jittered the sidebar and flashed skeletons (Home and Explore page state is now kept across sidebar switches, no reloading)
- 从每日推荐等页面切回推荐时，侧边栏抖动、首页闪骨架屏的问题（首页与精选的页面状态现在跨切换保留，不再重复加载）

## 0.1.0 - 2026-08-16

### Added / 新增

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
