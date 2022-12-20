# Pine

[![Swift 5](https://img.shields.io/badge/swift-5-orange.svg?style=flat)](https://github.com/apple/swift)
[![Platform](http://img.shields.io/badge/platform-macOS-red.svg?style=flat)](https://developer.apple.com/macos/)
[![Github](http://img.shields.io/badge/github-lukakerr-green.svg?style=flat)](https://github.com/lukakerr)
![Github All Releases](https://img.shields.io/github/downloads/lukakerr/pine/total.svg)

<p align="center">
  <img src="./Pine/Assets.xcassets/AppIcon.appiconset/pine-512@1x.png" width="150">
</p>

Pine是一个轻量级的macOS Markdown编辑器,不同于传统文档编辑器,它更专注于写作者本身,在保持简洁的同时,它还通过[以文档为核心的设计理念](https://developer.apple.com/document-based-apps)和兼具灵活性与专业性的数十项功能,赋予用户极高的效率与最大的可能性,同时还与Apple的[原生设计风格](https://developer.apple.com/macos/human-interface-guidelines)融会贯通.

### Installing

Pine仍处于测试阶段,因此,如果您遇到任何错误或对新的功能有什么要求,请在项目中添加一个`issue`.

**通过Homebrew安装**

```bash
$ brew tap lukakerr/things
$ brew install pine
```

**直接下载并安装**

请至[Releases](https://github.com/lukakerr/pine/releases)下载并安装.

### 卸载

**自Homebrew安装应用**

```bash
$ brew remove pine
```

**直接下载并安装应用**

```
$ rm -r /Applications/Pine.app ~/Library/Caches/io.github.lukakerr.pine
```

### 编译

**Make**

```bash
$ git clone git@github.com:lukakerr/pine.git
$ cd pine
$ make
```

**Xcode**

```bash
$ git clone git@github.com:lukakerr/pine.git
$ cd pine
$ open Pine.xcworkspace
```

### 测试

**Make**

```bash
$ make test
```

**Xcode**

按住<kbd>⌘</kbd>并点击<kbd>U</kbd>

### 参与并编写

请参阅[CONTRIBUTING.md](./CONTRIBUTING.md)以查看详细内容.

### Features

- 主题
- LaTex公式
- Github格式文档
- GithubEmoji("Hooray","Eyes"等......)
- Latex,Markdown,HTML自动补全
- 本地图片加载支持
- 拆分窗口
- 更好的全屏体验
- 完整的标签体系
- 文件夹(工作站)支持
- 自定义的`.css`主题
- 基于`.md`的文件共享
- 语法高亮及预览
- 自动保存
- 高效的版本控制系统
- 快捷方式(热键)与触控栏快照
- 自动补全标签
- 启用/禁用Markdown扩展
- 自定义字体
- 字数统计等写作分析

### Todo

- 预览`.css`文件
- 改善侧边栏操作逻辑
  - 更完整的文件夹显示
  - 上下文菜单中的更多实用操作

### Screenshots

<p align="center">
  <img src="https://i.imgur.com/vxAaNeX.png">
  <img src="https://i.imgur.com/5LQ1Ll4.png">
</p>
