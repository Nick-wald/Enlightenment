---
date: 2023-9-6
title: Enlightenment启明引擎开发文档
hide:
  - navigation
  - toc
---

!!! quote

    就在我人生之旅的中途，

    我在一座昏暗的森林之中醒悟过来，

    因为我在里面迷失了正确的道路。

    ——但丁《神曲·地狱篇》

![GitHub last commit (branch)](https://img.shields.io/github/last-commit/Nick-wald/Enlightenment/master)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/Nick-wald/Enlightenment)
![GitHub Repo stars](https://img.shields.io/github/stars/Nick-wald/Enlightenment)
![GitHub repo size](https://img.shields.io/github/repo-size/Nick-wald/Enlightenment)

## :smile: 欢迎

`Enlightenment启明`是基于`Godot`编写的RPG[^1]游戏开发引擎。其通过一系列 包 和 组件 ，实现整个游戏内容的管理和拓展。

无论您是使用者还是开发者，都建议先阅读开发文档中的[起步](guide)部分。


[^1]: 实际上，引擎还可以通过载入 包 的方式拓展支持的游戏类型和功能，而非单纯地仅仅支持RPG

*[组件]: 组件(Component)，主体包内多以*Manager的方式命名
*[包]: 包(Package)，内可含多个组件