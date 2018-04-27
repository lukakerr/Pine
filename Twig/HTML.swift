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
  
  // FIXME: fix this class
  // How this class should work:
  //  - copy resources to application support directory
  //  - get file path to css and js resources and insert them as the src/href into the HTML
  
  private init() {
    self.copyFiles()
    self.loadCSS()
//    self.loadJS()
  }
  
  var contents: String = ""
  var baseCSS: String = ""
  var css: String = ""
  var js: String = ""
  
  func getHTML() -> String {
    return(
      """
      <!DOCTYPE html>
      <html>
      <head>
      <style>
      \(self.css)
      \(self.baseCSS)
      pre code, p code {background: \(theme.code)!important}
      body {background: \(theme.background)}
      p, h1, h2, h3, h4, h5, h6, ul, ol, dl, li, table {
      color: \(theme.text);
      }
      </style>
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/\(theme.syntax).min.css">
      <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js">
      </script>
      <script>hljs.initHighlightingOnLoad();</script>
      </head>
      <body>
      \(self.contents)
      </body>
      </html>
      """
    )
  }
  
  func getApplicationSupportFolder() -> URL? {
    guard let folder = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask).first else { return nil }
    return folder
  }
  
  func loadJS() {
    guard let folder = getApplicationSupportFolder() else { return }
    let jsFile = folder.appendingPathComponent("highlight-js/highlight.js")
    
    guard let jsResult = try? String(contentsOf: jsFile, encoding: .utf8) else { return }
    
    self.js = jsResult
  }
  
  func loadCSS() {
    guard let folder = getApplicationSupportFolder() else { return }
    
    let baseCSSFile = folder.appendingPathComponent("Markdown.css")
    guard let baseCSSResult = try? String(contentsOf: baseCSSFile, encoding: .utf8) else { return }
    
//    guard let bundlePath = Bundle.main.resourcePath else { return }
//    let cssFolder = NSURL(fileURLWithPath: (String(describing: bundlePath) + "/highlight-js/styles/\(theme.syntax).css"))
//    guard let cssResult = try? String(contentsOf: cssFolder as URL, encoding: .utf8) else { return }

//    self.css = cssResult
    self.baseCSS = baseCSSResult
  }
  
  func copyFiles() {
    guard let folder = getApplicationSupportFolder() else { return }
    guard let cssFile = Bundle.main.path(forResource: "Markdown", ofType: "css") else { return }
    guard let bundlePath = Bundle.main.resourcePath else { return }
    let highlightFolder = NSURL(fileURLWithPath: (String(describing: bundlePath) + "/highlight-js"))
    
    try? FileManager.default.copyItem(at: highlightFolder as URL, to: folder.appendingPathComponent("highlight-js"))
    try? FileManager.default.copyItem(at: URL(fileURLWithPath: cssFile), to: folder.appendingPathComponent("Markdown.css"))
  }
  
}

let html = HTML.sharedInstance
