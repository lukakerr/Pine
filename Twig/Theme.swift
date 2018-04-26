//
//  Theme.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

enum ThemeType: String {
  case light, dark
}

class Theme {
  static let sharedInstance = Theme()
  
  private init(){}
  
  public var id: Int = 0
  public var type: ThemeType = ThemeType.light
  public var appearance: NSAppearance.Name = .vibrantLight
  public var syntax: String = "paraiso-light" {
    willSet(newSyntax) {
      defaults.setValue(newSyntax, forKey: "syntax")
    }
  }
  
  public func setTheme(_ theme: ThemeType) {
    self.type = theme
    if (self.type == ThemeType.light) {
      self.id = 0
      self.appearance = .vibrantLight
    } else {
      self.id = 1
      self.appearance = .vibrantDark
    }
    defaults.setValue(self.type.rawValue, forKey: "theme")
  }
  
}

let theme = Theme.sharedInstance
