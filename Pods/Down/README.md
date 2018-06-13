## Down
[![Build Status](https://travis-ci.org/iwasrobbed/Down.svg?branch=master)](https://travis-ci.org/iwasrobbed/Down)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/iwasrobbed/Down/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/Down.svg?maxAge=10800)]()
[![Swift 4](https://img.shields.io/badge/language-Swift-blue.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/OS-macOS-orange.svg)](https://developer.apple.com/macos/)
[![iOS](https://img.shields.io/badge/OS-iOS-orange.svg)](https://developer.apple.com/ios/)
[![tvOS](https://img.shields.io/badge/OS-tvOS-orange.svg)](https://developer.apple.com/tvos/)
[![Coverage Status](https://coveralls.io/repos/github/iwasrobbed/Down/badge.svg?branch=master)](https://coveralls.io/github/iwasrobbed/Down?branch=master)

Blazing fast Markdown rendering in Swift, built upon [cmark](https://github.com/jgm/cmark).

Is your app using it? [Let us know!](mailto:rob@robphillips.me)

#### Maintainers

- [Rob Phillips](https://github.com/iwasrobbed)
- [Keaton Burleson](https://github.com/128keaton)
- [Tony Arnold](https://github.com/tonyarnold)
- [Ken Harris](https://github.com/kengruven)
- [Other contributors](https://github.com/iwasrobbed/Down/graphs/contributors) 🙌 

### Installation

Note: Swift 4 support is now on the `master` branch and any tag >= 0.4.x (Swift 3 is 0.3.x)

Quickly install using [CocoaPods](https://cocoapods.org): 

```ruby
pod 'Down'
```

Or [Carthage](https://github.com/Carthage/Carthage):

```
github "iwasrobbed/Down"
```
Due to limitations in Carthage regarding platform specification, you need to define the platform with Carthage. 

e.g.

```carthage update --platform iOS```

Or manually install:

1. Clone this repository
2. Build the Down project
3. Add the resulting framework file to your project
4. ?
5. Profit

### Robust Performance

>[cmark](https://github.com/jgm/cmark) can render a Markdown version of War and Peace in the blink of an eye (127 milliseconds on a ten year old laptop, vs. 100-400 milliseconds for an eye blink). In our [benchmarks](https://github.com/jgm/cmark/blob/master/benchmarks.md), cmark is 10,000 times faster than the original Markdown.pl, and on par with the very fastest available Markdown processors.

> The library has been extensively fuzz-tested using [american fuzzy lop](http://lcamtuf.coredump.cx/afl). The test suite includes pathological cases that bring many other Markdown parsers to a crawl (for example, thousands-deep nested bracketed text or block quotes).

### Output Formats
* Web View (see DownView class)
* HTML
* XML
* LaTeX
* groff man
* CommonMark Markdown
* NSAttributedString
* AST (abstract syntax tree)

### View Rendering

The `DownView` class offers a very simple way to parse a UTF-8 encoded string with Markdown and convert it to a web view that can be added to any view:

```swift
let downView = try? DownView(frame: self.view.bounds, markdownString: "**Oh Hai**") {
    // Optional callback for loading finished
}
// Now add to view or constrain w/ Autolayout
// Or you could optionally update the contents at some point:
try? downView?.update(markdownString:  "## [Google](https://google.com)") {
    // Optional callback for loading finished
}
```

Meta example of rendering this README:

![Example gif](Images/ohhai.gif)

##### Prevent zoom
The default implementation of the `DownView` allows for zooming in the rendered content. If you want to disable this, then you’ll need to instantiate the `DownView` with a custom bundle where the `viewport` in `index.html` has been assigned `user-scalable=no`. More info can be found [here](https://github.com/iwasrobbed/Down/pull/30).

### Parsing API

The `Down` struct has everything you need if you just want out-of-the-box setup for parsing and conversion. 

```swift
let down = Down(markdownString: "## [Down](https://github.com/iwasrobbed/Down)")

// Convert to HTML
let html = try? down.toHTML()
// "<h2><a href=\"https://github.com/iwasrobbed/Down\">Down</a></h2>\n"

// Convert to XML
let xml = try? down.toXML()
// "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n<document xmlns=\"http://commonmark.org/xml/1.0\">\n  <heading level=\"2\">\n    <link destination=\"https://github.com/iwasrobbed/Down\" title=\"\">\n      <text>Down</text>\n    </link>\n  </heading>\n</document>\n"

// Convert to groff man
let man = try? down.toGroff()
// ".SS\nDown (https://github.com/iwasrobbed/Down)\n"

// Convert to LaTeX
let latex = try? down.toLaTeX()
// "\\subsection{\\href{https://github.com/iwasrobbed/Down}{Down}}\n"

// Convert to CommonMark Markdown
let commonMark = try? down.toCommonMark()
// "## [Down](https://github.com/iwasrobbed/Down)\n"

// Convert to an attributed string
let attributedString = try? down.toAttributedString()
// NSAttributedString representation of the rendered HTML;
// by default, uses a stylesheet that matches NSAttributedString's default font,
// but you can override this by passing in your own, using the 'stylesheet:' parameter.

// Convert to abstract syntax tree
let ast = try? down.toAST()
// Returns pointer to AST that you can manipulate

```

### Rendering Granularity

If you'd like more granularity for the output types you want to support, you can create your own struct conforming to at least one of the renderable protocols:

* DownHTMLRenderable
* DownXMLRenderable
* DownLaTeXRenderable
* DownGroffRenderable
* DownCommonMarkRenderable
* DownASTRenderable
* DownAttributedStringRenderable

Example:

```swift
public struct MarkdownToHTML: DownHTMLRenderable {
    /**
     A string containing CommonMark Markdown
    */
    public var markdownString: String

    /**
     Initializes the container with a CommonMark Markdown string which can then be rendered as HTML using `toHTML()`

     - parameter markdownString: A string containing CommonMark Markdown

     - returns: An instance of Self
     */
    @warn_unused_result
    public init(markdownString: String) {
        self.markdownString = markdownString
    }
}
```

### Options

Each protocol has options that will influence either rendering or parsing:

```swift
/**
 Default options
*/
public static let `default` = DownOptions(rawValue: 0)

// MARK: - Rendering Options

/**
 Include a `data-sourcepos` attribute on all block elements
*/
public static let sourcePos = DownOptions(rawValue: 1 << 1)

/**
 Render `softbreak` elements as hard line breaks.
*/
public static let hardBreaks = DownOptions(rawValue: 1 << 2)

/**
 Suppress raw HTML and unsafe links (`javascript:`, `vbscript:`,
 `file:`, and `data:`, except for `image/png`, `image/gif`,
 `image/jpeg`, or `image/webp` mime types).  Raw HTML is replaced
 by a placeholder HTML comment. Unsafe links are replaced by
 empty strings.
*/
public static let safe = DownOptions(rawValue: 1 << 3)

// MARK: - Parsing Options

/**
 Normalize tree by consolidating adjacent text nodes.
*/
public static let normalize = DownOptions(rawValue: 1 << 4)

/**
 Validate UTF-8 in the input before parsing, replacing illegal
 sequences with the replacement character U+FFFD.
*/
public static let validateUTF8 = DownOptions(rawValue: 1 << 5)

/**
 Convert straight quotes to curly, --- to em dashes, -- to en dashes.
*/
public static let smart = DownOptions(rawValue: 1 << 6)
```

### Supports
Swift; iOS 9+, tvOS 9+, macOS 10.11+

### Markdown Specification

Down is built upon the [CommonMark](http://commonmark.org) specification.

### A little help from my friends
Please feel free to fork and create a pull request for bug fixes or improvements, being sure to maintain the general coding style, adding tests, and adding comments as necessary.

### Credit
This library is a wrapper around [cmark](https://github.com/jgm/cmark), which is built upon the [CommonMark](http://commonmark.org) Markdown specification. 

[cmark](https://github.com/jgm/cmark) is Copyright (c) 2014 - 2017, John MacFarlane. View [full license](https://github.com/jgm/cmark/blob/master/COPYING).
