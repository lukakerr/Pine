//
//  HTML.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

class HTML {

  static let sharedInstance = HTML()

  // Currently WKWebView doesn't allow local resources to be loaded (css, js)
  // via file:/// so we have to read from the file and insert it into the html inline
  // This file IO only happens when the singleton is instantiated, but the WKWebView
  // has to re-parse the entire HTML returned from getHTML()
  private init() {
    self.copyFiles()
    self.loadCSS()
    self.loadJS()
  }

  var baseCSS: String = ""
  var css: String = ""
  var js: String = ""
  var y: Int = 0

  // The innerHTML contents are passed in here rather than stored
  // to prevent asynchronous race conditions changing the content on startup
  public func getHTML(with contents: String) -> String {
    return(
      """
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          \(css)
          \(baseCSS)
          code { background: \(theme.code.hex) !important }
          p, h1, h2, h3, h4, h5, h6, ul, ol, dl, li, table, tr { color: \(theme.text.hex); }
          table tr { background: \(theme.background.hex); }
          table tr:nth-child(2n) { background: \(theme.background.darker.hex); }
          table tr th, table tr td { border-color: \(theme.background.lighter.hex) }
        </style>
        <script>\(js)</script>
        <script>hljs.initHighlightingOnLoad();</script>

        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0/katex.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0/katex.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0/contrib/auto-render.min.js"></script>
      </head>
      <body>
        \(contents)
        <script>
          window.scrollTo(0, \(y));
        </script>
        <script>
          renderMathInElement(document.body, {delimiters: [
            {left: "$$", right: "$$", display: true},
            {left: "$", right: "$", display: false},
          ]});
        </script>
      </body>
      </html>
      """
    )
  }

  fileprivate func getApplicationSupportFolder() -> URL? {
    return FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask).first
  }

  fileprivate func loadJS() {
    guard
      let jsFile = getApplicationSupportFolder()?.appendingPathComponent("highlight-js/highlight.js"),
      let jsResult = try? String(contentsOf: jsFile, encoding: .utf8)
    else { return }

    js = jsResult
  }

  fileprivate func loadCSS() {
    guard
      let folder = getApplicationSupportFolder(),
      let bundlePath = Bundle.main.resourcePath,
      let baseCSSResult = try? String(contentsOf: folder.appendingPathComponent("Markdown.css"), encoding: .utf8)
    else { return }

    let cssFolder = URL(fileURLWithPath: bundlePath + "/highlight-js/styles/\(theme.syntax).css")

    if let cssResult = try? String(contentsOf: cssFolder as URL, encoding: .utf8) {
      css = cssResult
      baseCSS = baseCSSResult
    }
  }

  fileprivate func copyFiles() {
    guard
      let folder = getApplicationSupportFolder(),
      let cssFile = Bundle.main.path(forResource: "Markdown", ofType: "css"),
      let bundlePath = Bundle.main.resourcePath
    else { return }

    let highlightFolder = URL(fileURLWithPath: (String(describing: bundlePath) + "/highlight-js"))

    try? FileManager.default.copyItem(
      at: highlightFolder as URL,
      to: folder.appendingPathComponent("highlight-js")
    )

    try? FileManager.default.copyItem(
      at: URL(fileURLWithPath: cssFile),
      to: folder.appendingPathComponent("Markdown.css")
    )
  }

}

let html = HTML.sharedInstance
