//
//  Theme.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Highlightr

class Theme {
  static let sharedInstance = Theme()

  public var highlightr = Highlightr()!

  public var code: NSColor = .gray
  public var text: NSColor = .black
  public var background: NSColor = .white

  private init() {
    // Restore default syntax theme
    if let defaultSyntax = defaults.string(forKey: "syntax") {
      self.syntax = defaultSyntax
    }
  }

  // Default theme is gruvbox-dark
  public var syntax: String = "gruvbox-dark" {
    willSet(newSyntax) {
      defaults.setValue(newSyntax, forKey: "syntax")
    }
  }

}

let theme = Theme.sharedInstance
