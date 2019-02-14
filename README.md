# Twig

[![Swift 4.2](https://img.shields.io/badge/swift-4.2-orange.svg?style=flat)](https://github.com/apple/swift)
[![Platform](http://img.shields.io/badge/platform-macOS-red.svg?style=flat)](https://developer.apple.com/macos/)
[![Github](http://img.shields.io/badge/github-lukakerr-green.svg?style=flat)](https://github.com/lukakerr)
![Github All Releases](https://img.shields.io/github/downloads/lukakerr/twig/total.svg)

<p align="center">
  <img src="./Twig/Assets.xcassets/AppIcon.appiconset/twig-512.png" width="200">
</p>


Twig is lightweight macOS markdown editor. It's currently a work in progress.

It is a [document based application](https://developer.apple.com/document-based-apps), and aims to follow Apple's [Human Interface Guidelines](https://developer.apple.com/macos/human-interface-guidelines)

### Features/Todo

| Feature                                    | Completed?                                |
| ------------------------------------------ | ----------------------------------------- |
| Themeable                                  | **Yes**                                   |
| Math support (LaTeX subset)                | **Yes**                                   |
| Github flavored markdown                   | **Yes**                                   |
| Exporting to PDF, HTML, TXT, RST, RTF      | Partly - [contribute](./CONTRIBUTING.md) |
| Toggleable split view                      | **Yes**                                   |
| Full screen support                        | **Yes**                                   |
| Tab support                                | **Yes**                                   |
| Workspace/folder support                   | Partly - [contribute](./CONTRIBUTING.md) |
| Horizontal and vertical split view         | **Yes**                                   |
| Ability to create custom `.css` themes     | **Yes**                                   |
| Sparkle auto updating framework            | No - [contribute](./CONTRIBUTING.md)     |
| Ability to share `.md` files               | **Yes**                                   |
| Syntax highlighting for source and preview | **Yes**                                   |
| Autosaving                                 | **Yes**                                   |
| Version control and history recovery       | **Yes**                                   |
| Markdown shortcuts                         | **Yes**                                   |
| Auto pair markdown tags                    | No - [contribute](./CONTRIBUTING.md)      |
| Custom font                                | **Yes**                                   |
| Ability to edit preview `.css`             | No - [contribute](./CONTRIBUTING.md)     |
| Word count                                 | **Yes**                                   |

### Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details on how to contribute.

### Installing

Twig is still in its very early stages, so if you encounter any bugs or have a feature request please raise an issue!

**Install via Homebrew Cask**

```bash
$ brew cask install twig
```

**Manual Download**

Visit the [releases page](https://github.com/lukakerr/twig/releases) to download manually.

### Uninstalling

**Download via Homebrew Cask**

```bash
$ brew cask remove twig
```

**Downloaded Manually**

```
$ rm -r /Applications/Twig.app
$ rm -r ~/Library/Caches/io.github.lukakerr.twig
```

### Building

To build and run, clone this repository, open in Xcode and hit "Run".

```bash
$ git clone git@github.com:lukakerr/twig.git
$ cd twig
$ pod install
$ open Twig.xcworkspace
```

### Screenshots

<p align="center">
  <img src="https://i.imgur.com/wkB9u8W.png">
</p>
