# Changelog

[Unreleased]
### New Features
- Added autocomplete support for LaTeX, HTML and markdown with preferences to disable each
- Added support for WikiLink (`[[Description|./path/to/note.md]]`) markdown extensions
- Added RTL writing direction support in editor and preview
- Added preference to show invisible characters
- Added preference to show a toolbar on the window
- Added preferences to sync scroll position between editor and preview
- Added 9 new themes:
  - a11y-dark
  - a11y-light
  - an-old-hope
  - gml
  - isbl-editor-dark
  - isbl-editor-light
  - lightfair
  - nord
  - shades-of-purple

### Fixes
- Fix some themes having incorrect colors
- Fix `open -a` not working at times
- Set a max width for `<video>` HTML elements so they don't overflow
- Fix indented markdown lists not getting syntax highlighted
- Fix words breaking on any character, now breaking on words
- Fix vertical scrollbar not showing in preferences when scrolled

### Other
- Refactored sidebar and tabs
- Now using [custom Highlightr fork](https://github.com/lukakerr/Highlightr)
- Added library licenses to the 'About' window
- Added new UI tests

## [0.0.8] - 2019-03-10
### New Features
- Ability to open files and folders via `open -a /Applications/Pine.app file.md folder/`

### Fixes
- Set syntax highlighting theme when changed in preview

### Other

## [0.0.7] - 2019-03-09
### New Features
- GitHub emoji support
- Footnote support
- New preferences layout
- Preferences for enabling/disabling markdown extensions
- Paste image(s) directly into the editor and have them be inserted in markdown format
- New icons used for sidebar files/folders
- Button to set Pine as the default Markdown application

### Fixes
- Fix possible crash when changing preferences

### Other
- Renamed to Pine
- Add a Makefile to improve building/releasing

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
