# Changelog

[Unreleased]
### New Features

### Fixes

### Other

## [0.0.6] - 2019-02-24
### New Features
- Add a markdown reference window accessed by `⌘ .`
- Save window size and position across launches
- Add certain shortcuts to Touch Bar
- Add .txt exporting support

### Fixes
- Fix a few minor inconsistencies in the preview styling
- Fix out of range bounds error when autopairing

### Other
- Add a proper swift version under .swift-version
- Add a `Docs/` folder

## [0.0.5] - 2019-02-20
### New Features
- Auto pairing of markdown syntax (with a preference to disable)
- Ability to view local images in the preview using relative and absolute paths
- H6 `###### ` shortcut is now available under Format > Heading 6
- Ability to open linked markdown documents from the preview
- Ability to remove top level sidebar items from the sidebar (files and folders)
- Support for `.markdown` files
- Sidebar folder structure now is in sync across all tabs/windows
- 'Untitled' documents are now replaced when opening a file if no changed have been made

### Fixes
- Inserting a heading via a shortcut now correctly inserts it at the start of the line
- Whitespace, unicode and other special characters are handled in files
- Editor toggle shortcut is fixed and now working
- Sidebar toggle button is fixed and now working
- Long words now break to the next line rather than overflowing the preview bounds

### Other
- More unit tests
- Syntax highlighting speed improvements

## [0.0.4] - 2019-02-10
### New Features
- Ability to set sidebar background color to match overall theme

### Fixes
- Disable spellcheck by default
- Make tab indentation in preview display as 2 spaces

### Other
- Add unit tests for markdown shortcuts

## [0.0.3] - 2018-09-18
### New Features
- Exporting to LaTeX
- Exporting to XML
- Add preference for enabling/disabling spell checking

### Fixes
- Fixed red underline from not showing in misspelled words
- Fixed newlines `\\` not creating a new line when using LaTeX math blocks
- Fixed build errors when not using Swift 4.2

### Other
- Use the `cmark-gfm-swift` Pod, rather than having it as a library

## [0.0.2] - 2018-08-10
### New Features
- Keyboard shortcuts for markdown tags (bold, italics, strikethrough, code, code block, headers, math, math blocks)
- Ability to toggle editor

### Fixes
- Fix background color not applying on HTML export
- Fix multiple instances of the preferences window appearing
- Re-generate preview when it is un-hidden

### Other
- Use system icons for sidebar folder/files
- Update error message when unable to write/read from file
- Use system toggle for sidebar (now shows "Hide"/"Show" sidebar, rather than "Toggle")

## [0.0.1] - 2018-07-01
### New Features
- Created Twig
