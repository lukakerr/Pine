# cmark-gfm-swift

A Swift wrapper of cmark with GitHub Flavored Markdown extensions.

### Usage

**Import the framework**

```swift
import cmark_gfm_swift
```

**Render Markdown to HTML**

```swift
let markdownText = """
## Heading
"""

if let parsed = Node(markdown: markdownText)?.html {
  print("HTML parsed: \(parsed)")
}
```

**Enabling Markdown extensions and options**

```swift
let markdownText = """
## Heading
"""

// List of markdown options
var options: [MarkdownOptions] = [
  .footnotes // Footnote syntax
]

// List of markdown extensions
var extensions: [MarkdownExtensions] = [
  .emoji, // GitHub emojis
  .table, // Tables
  .autolink, // Autolink URLs
  .mention, // GitHub @ mentions
  .checkbox, // Checkboxes
  .wikilink, // WikiLinks
  .strikethrough // Strikethrough
]

if let parsed = Node(
  markdown: markdownText,
  options: options,
  extensions: extensions
)?.html {
  print("HTML parsed: \(parsed)")
}
```

### Resources

- [GFM spec](https://github.github.com/gfm/) with [blog post](https://githubengineering.com/a-formal-spec-for-github-markdown/)
- [CommonMark extensions](https://github.com/commonmark/CommonMark/wiki/Deployed-Extensions)
- [Using cmark gfm extensions](https://medium.com/@krisgbaker/using-cmark-gfm-extensions-aad759894a89)

### Acknowledgements

- [cmark](https://github.com/commonmark/cmark)
- [GitHub cmark fork](https://github.com/github/cmark)
- [commonmark-swift](https://github.com/chriseidhof/commonmark-swift)
- [libcmark_gfm](https://github.com/KristopherGBaker/libcmark_gfm)
