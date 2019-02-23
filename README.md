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
$ rm -r /Applications/Twig.app ~/Library/Caches/io.github.lukakerr.twig
```

### Building

To build and run, clone this repository, open in Xcode and hit "Run".

```bash
$ git clone git@github.com:lukakerr/twig.git
$ cd twig
$ open Twig.xcworkspace
```

### Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details on how to contribute.

### Features

- Themeable
- Math support (LaTeX subset)
- GitHub Flavored Markdown
- Local image support
- Toggleable split view (horizontal and vertical split)
- Full screen support
- Tab support
- Folder support
- Ability to create custom `.css` themes
- Ability to share `.md` files
- Syntax highlighting for source and preview
- Autosaving
- Version control and history recovery
- Markdown shortcuts (keyboard and Touch Bar shortcuts)
- Auto pair markdown tags
- Custom font
- Word count

### Todo

- Add ability to edit preview `.css`
- Improve sidebar
  - Folder watching
  - More actions in contextual menu

### Screenshots

<p align="center">
  <img src="https://i.imgur.com/YPyYQQH.png">
  <img src="https://i.imgur.com/rEPH0oR.png">
</p>
