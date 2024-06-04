---
title: "Firefox 使用 mpv 播放视频"
date: "2024-06-04"
description: ""
summary: "ff"
categories: [ "linux" ]
---

参考文章

- [mpv使用yt-dlp播放在线视频的配置](https://www.bilibili.com/read/cv27371446/)

## 安装 yt-dlp

mpv 默认调用 `youtube-dl` 缓存视频，这里用 `yt-dlp` 替代：

```bash-session
# emerge -av net-misc/yt-dlp
```
## 配置 mpv

编辑 `~/.config/mpv/mpv.conf`：

```bash
# 优先硬解码
hwdec=auto

# 缓存
cache=yes
# 视频预缓存上限
demuxer-max-bytes=500MiB
# 视频已播放部分缓存上限
demuxer-max-back-bytes=200MiB

# 使用 yt-dlp 替代默认的 youtube-dl
script-opts=ytdl_hook-ytdl_path=/usr/bin/yt-dlp
script-opts-append=ytdl_hook-ytdl_path=/usr/bin/yt-dlp

# 指定默认播放h264格式1080p的在线视频
#ytdl-format="((bestvideo[height<=?1080][vcodec^=avc1]/bestvideo)+(bestaudio[acode=aac]/bestaudio))"
# 指定默认播放hevc格式4K的在线视频
ytdl-format="((bestvideo[height<=?3840][vcodec^=hev1]/bestvideo)+(bestaudio[acode=aac]/bestaudio))"
```

编辑 `.config/yt-dlp/config`：

```bash
# 指定使用的浏览器 cookies
--cookies-from-browser Firefox
# 指定下载目录以及命名规则
-o ~/Videos/%(title)s.%(ext)s
# 指定下载视频格式及分辨率，与 mpv.conf 写法相同
-f "((bestvideo[height<=?3840][vcodec^=avc1]/bestvideo)+(bestaudio[acode=aac]/bestaudio))"
```

## 安装 ff2mpv 扩展

[Firefox 扩展地址](https://addons.mozilla.org/en-US/firefox/addon/ff2mpv/)

### 扩展配置

参考：[ff2mpv wiki / Installation](https://github.com/woodruffw/ff2mpv/wiki/)

下载：[ff2mpv](https://github.com/woodruffw/ff2mpv/tags)

安装：解压后当前用户执行 `./install.sh`

