//
//  Theme.swift
//  Pine
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Highlightr

enum ThemeKeys {
  static let syntax = "syntax"
}

class Theme {
  static let shared = Theme()

  // Default theme is github-gist
  static let defaultTheme = "github-gist"

  public var highlightr = Highlightr()!

  public var code: NSColor = .gray
  public var text: NSColor = .black
  public var background: NSColor = .white

  private init() {
    // Restore default syntax theme
    if let defaultSyntax = defaults.string(forKey: ThemeKeys.syntax) {
      self.syntax = defaultSyntax
      self.setTheme(to: self.syntax)
    }
  }

  public var syntax: String = Theme.defaultTheme {
    willSet(newSyntax) {
      defaults.setValue(newSyntax, forKey: ThemeKeys.syntax)
    }
  }

  /// Set the theme given a theme name
  public func setTheme(to theme: String) {
    self.syntax = theme
    self.highlightr.setTheme(to: theme)
    self.background = self.highlightr.theme.themeBackgroundColor
  }

  /// Set the theme's font
  public func setFont(to font: NSFont) {
    self.highlightr.theme.setCodeFont(font)
  }

}

let theme = Theme.shared
