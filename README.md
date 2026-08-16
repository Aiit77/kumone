# Kumone

雲の音 — 原生 macOS 网易云音乐客户端。SwiftUI 编写，零第三方依赖，直连网易云真实 API（自实现 weapi / eapi 加密），UI 设计参考 [kaset](https://github.com/sozercan/kaset)，功能参考 [YesPlayMusic](https://github.com/qier222/YesPlayMusic)。

![icon](docs/icon.png)

## 功能

- **扫码登录** — 网易云 App 扫码，Cookie 本地持久化
- **推荐** — 每日推荐、私人漫游、心动模式、推荐歌单、排行榜、新碟上架、推荐歌手
- **精选** — 分类歌单（含精品歌单、官方、排行榜）无限滚动
- **播放** — AVPlayer 引擎，音质可选（标准 ~ Hi-Res，自动回落），随机 / 单曲循环 / 列表循环，下一首播放队列，灰色歌曲识别（VIP / 无版权 / 下架）
- **灰色歌曲解锁** — 原生实现 UnblockNeteaseMusic 核心音源（pyncmd / 酷我 / 酷狗），无版权或试听歌曲自动匹配第三方音源
- **沉浸播放页** — 封面取色渐变背景 + 大封面 + 大字同步歌词（点击播放条封面进入，ESC 退出）
- **私人漫游（FM）** — 沉浸式页面，不喜欢 / 切歌
- **歌词** — 侧边玻璃面板，逐行同步 + 翻译，点击跳转
- **音乐库** — 我喜欢的音乐、创建 / 收藏的歌单、收藏专辑 / 关注歌手、最近播放、音乐云盘
- **歌单管理** — 新建 / 删除 / 收藏歌单、添加 / 移除歌曲、红心
- **搜索** — 综合 / 单曲 / 歌手 / 专辑 / 歌单，热搜词占位
- **系统集成** — Now Playing（媒体键 / 控制中心）、听歌打卡（scrobble）、播放状态恢复

## 构建

要求 macOS 15+、Xcode 26+。

```bash
swift build                    # 编译
Scripts/build-app.sh           # 打包 .app（.build/app/Kumone.app）
Scripts/compile_and_run.sh     # 杀进程 → 重新打包 → 启动
```

## 架构

```
Sources/Kumone/
├── Core/
│   ├── API/            # NeteaseCrypto（weapi/eapi 加密）、NeteaseClient（传输 + Cookie）、NeteaseAPI（约 50 个端点）
│   ├── Models/         # 统一 Track 模型（兼容新旧两种 JSON 格式）、歌词解析器
│   ├── Player/         # PlayerService（队列 / 随机 / 循环 / FM / URL 解析）、NowPlayingManager
│   └── Storage/        # AccountStore、SettingsManager、两级图片缓存
├── DesignSystem/       # 设计 token、按钮样式（hover 缩放 / 行高亮 / chip）、骨架屏、卡片、跑马灯
└── Features/           # 各页面 + 播放条 + 歌词/队列面板
```

## 说明

仅供学习交流，音乐数据与版权归网易云音乐所有。不支持下载、无社交功能。
