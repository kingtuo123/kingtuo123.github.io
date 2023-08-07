---
title: "MPD PulseAudio 配置"
date: "2022-07-10"
description: ""
summary: "解决 MPD 与其他应用音频冲突"
categories: [  "gentoo","linux" ]
tags: [ "gentoo","linux" ]
---

- 问题：`MPD` 与其他应用如 `Firefox` 冲突，导致另一个应用没有声音

## MPD

编辑 `/etc/mpd.conf`

```text
user                "mpd"

music_directory     "/var/lib/mpd/music"
playlist_directory  "/var/lib/mpd/playlists"
db_file             "/var/lib/mpd/database"
log_file            "/var/lib/mpd/log"
pid_file            "/var/lib/mpd/pid"
state_file          "/var/lib/mpd/state"

bind_to_address     "127.0.0.1"
port                "6600"

restore_paused      "yes"

audio_output {
       type     "pulse"
       name     "My PULSE Device"
       server   "127.0.0.1"
}
```

> 注意 `server` 不要填 `localhost` ，因为 `MPD` 可能会访问 `ipv6` 的 `localhost` 即 `::1`，导致连接失败

> 可能需要添加 `mpd` 到 `audio` 组

`/var/lib/mpd/music` 存放用户音频，这里我用的链接到用户目录

```shell
$ ls -al /var/lib/mpd/music
lrwxrwxrwx 1 root root 17 Jun 10 21:16 /var/lib/mpd/music -> /home/king/Music/

$ ls -ld Music/
drwxr-xr-x 2 mpd audio 12288 Jun 19 06:41 Music/
```


## PulseAudio

编辑 `/etc/pulse/default.pa` ，增加下面一行

```text
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
```
