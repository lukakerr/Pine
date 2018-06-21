//
//  Theme.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class Theme {
  static let sharedInstance = Theme()
  
  public var code: NSColor = .white
  public var text: NSColor = .white
  public var background: NSColor?
  
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
