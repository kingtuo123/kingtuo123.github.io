---
title: "Docker 代理配置"
date: "2024-06-04"
description: ""
summary: "docker proxy"
categories: [ "docker" ]
tags: [ "docker" ]
---

参考文章：

- [move proxy settings to "proxies" struct within daemon.json](https://github.com/moby/moby/pull/43448)
- [How to Configure Docker to Use Proxy](https://itslinuxfoss.com/configure-docker-proxy/)
- [如何优雅的给 Docker 配置网络代理](https://www.cnblogs.com/Chary/p/18096678)

## Docker pull

编辑 `/etc/docker/daemon.json`：

```json
{
  "proxies": {
    "http-proxy": "127.0.0.1:1080",
    "https-proxy": "127.0.0.1:1080",
    "no-proxy": "localhost,127.0.0.1"
  }
}
```

`no-proxy` 表示不走代理的主机、域名或 IP，多个值用逗号分隔。可以使用通配符，如果 `"no-proxy": "*"`，所有请求都不走代理


此配置只作用于 dockerd，容器 containerd 代理由 `~/.docker/config.json` 配置

## Docker build

指定 `--build-arg` 参数：

```text
docker build . \
    --network host \
    --build-arg "HTTP_PROXY=http://127.0.0.1:1080" \
    --build-arg "HTTPS_PROXY=http://127.0.0.1:1080" \
    --build-arg "NO_PROXY=localhost,127.0.0.1" \
    -t image:tag
```

docker build 默认网络是 bridge，所以本地代理需设置 `--network host`
