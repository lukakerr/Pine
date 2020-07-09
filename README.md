# Pine

[![Swift 5](https://img.shields.io/badge/swift-5-orange.svg?style=flat)](https://github.com/apple/swift)
[![Platform](http://img.shields.io/badge/platform-macOS-red.svg?style=flat)](https://developer.apple.com/macos/)
[![Github](http://img.shields.io/badge/github-lukakerr-green.svg?style=flat)](https://github.com/lukakerr)
![Github All Releases](https://img.shields.io/github/downloads/lukakerr/pine/total.svg)

<p align="center">
  <img src="./Pine/Assets.xcassets/AppIcon.appiconset/pine-512@1x.png" width="150">
</p>


Pine is lightweight macOS markdown editor. It's currently a work in progress.

It is a [document based application](https://developer.apple.com/document-based-apps), and aims to follow Apple's [Human Interface Guidelines](https://developer.apple.com/macos/human-interface-guidelines)

### Installing

Pine is still in its very early stages, so if you encounter any bugs or have a feature request please raise an issue!

**Install via Homebrew Cask**

```bash
$ brew tap lukakerr/things
$ brew cask install pine
```

**Manual Download**

Visit the [releases page](https://github.com/lukakerr/pine/releases) to download manually.

### Uninstalling

**Installed via Homebrew Cask**

```bash
$ brew cask remove pine
```

**Downloaded Manually**

```
$ rm -r /Applications/Pine.app ~/Library/Caches/io.github.lukakerr.pine
```

### Building

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

### Testing

**Make**

```bash
$ make test
```

**Xcode**

Hit <kbd>⌘</kbd> <kbd>U</kbd>

### Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details on how to contribute.

### Features

- Themeable
- Math support (LaTeX subset)
- GitHub Flavored Markdown
- GitHub Emoji support
- LaTeX, Markdown and HTML autocomplete
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
- Enable/disable markdown extensions
- Custom font
- Word count

### Todo

- Add ability to edit preview `.css`
- Improve sidebar
  - Folder watching
  - More actions in contextual menu

### Screenshots

<p align="center">
  <img src="https://i.imgur.com/vxAaNeX.png">
  <img src="https://i.imgur.com/5LQ1Ll4.png">
</p>
