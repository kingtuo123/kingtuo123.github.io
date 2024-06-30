---
title: "Firefox 使用 mpv 播放视频"
date: "2024-06-04"
description: ""
summary: "firefox mpv"
categories: [ "linux" ]
---

## 安装 yt-dlp

mpv 默认调用 `youtube-dl` 解析视频链接，这里用 `yt-dlp` 替代：

```bash-session
# emerge -av net-misc/yt-dlp
```

安装的 `/usr/bin/youtube-dl`，实际调用的 `yt-dlp`：


```bash-session
$ cat /usr/bin/youtube-dl
 #!/bin/sh
 exec yt-dlp --compat-options youtube-dl "$@"
```

## 配置 mpv

编辑 `~/.config/mpv/mpv.conf`：

```bash
# 硬解码
hwdec=vaapi

# 缓存
cache=yes
# 视频预缓存上限
demuxer-max-bytes=500MiB
# 视频已播放部分缓存上限
demuxer-max-back-bytes=200MiB

# 指定默认播放avc/h264格式4K的在线视频
ytdl-format="((bestvideo[height<=?3840][vcodec^=avc]/bestvideo)+(bestaudio[acode=aac]/bestaudio))"
```

## 配置 yt-dlp

编辑 `.config/yt-dlp/config`：

```bash
# 指定使用的浏览器 cookies
--cookies-from-browser Firefox
# 指定下载目录以及命名规则
-o ~/Videos/%(title)s.%(ext)s
# 指定使用aria2c下载器
--external-downloader aria2c
# 8线程、分片，每份1M
--downloader-args aria2c:"-x 8 -k 1M"
# 指定下载视频格式及分辨率
-f "((bestvideo[height<=?3840][vcodec^=avc]/bestvideo)+(bestaudio[acode=aac]/bestaudio))"
```

## 安装 ff2mpv 扩展

第一步：安装 [Firefox ff2mpv 浏览器扩展](https://addons.mozilla.org/en-US/firefox/addon/ff2mpv/)

第二步：安装 [ff2mpv](https://github.com/woodruffw/ff2mpv/tags)，下载解压后当前用户执行 `./install.sh`
