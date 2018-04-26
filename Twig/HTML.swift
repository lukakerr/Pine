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
  
  private init() {
    self.loadCSS()
  }
  
  var contents: String = ""
  var css: String = ""
  
  func getHTML() -> String {
    return(
      """
      <!DOCTYPE html>
      <html>
      <head>
      <style>
      \(self.css)
      </style>
      </head>
      <body>
      \(self.contents)
      </body>
      </html>
      """
    )
  }
  
  func loadCSS() {
    guard let folder = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask).first else { return }
    
    let file = folder.appendingPathComponent("Markdown.css")
    
    guard let result = try? String(contentsOf: file, encoding: .utf8) else {
      // File doesn't exist, lets create it and use Markdown.css in resources for now
      if let cssFile = Bundle.main.path(forResource: "Markdown", ofType: "css") {
        let location = URL(fileURLWithPath: cssFile)
        
        // Use Markdown.css from resources
        guard let contents = try? String(contentsOf: location, encoding: .utf8) else {
          return
        }
        self.css = contents
        
        // Copy Markdown.css from resources to Application Support directory
        try? FileManager.default.copyItem(at: location, to: file)
      }
      return
    }

    self.css = result
  }
  
}

let html = HTML.sharedInstance
