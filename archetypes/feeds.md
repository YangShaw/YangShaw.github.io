+++
date = '{{ .Date }}'
draft = false
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
description = '一句话摘要（用于 SEO / OpenGraph）。'
author = 'YangShaw'
tags = ['feed']
categories = ['feeds']
+++

这里写正文内容（这是展示在 feeds 卡片里的主体）。

可选：用 `<!--more-->` 控制摘要。
