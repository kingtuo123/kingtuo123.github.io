---
title: "Fcitx Rime 简体中文设置"
date: "2023-03-12"
description: ""
summary: "解决 fcitx rime 默认繁体中文的问题"
tags: [ "linux" ]
categories: [ "linux" ]
---

## 配置简体中文

编辑 `~/.config/fcitx/rime/build/luna_pinyin.schema.yaml`

```
switches:
  - name: ascii_mode
    reset: 0
    states: ["中文", "西文"]
  - name: full_shape
    states: ["半角", "全角"]
  - name: simplification
    states: ["漢字", "汉字"]
  - name: ascii_punct
    states: ["。，", "．，"]
```

改为：

```
switches:
  - name: ascii_mode
    reset: 0
    states: ["中文", "西文"]
  - name: full_shape
    states: ["半角", "全角"]
  - name: simplification
    reset: 1
    states: ["漢字", "汉字"]
  - name: ascii_punct
    states: ["。，", "．，"]
```
