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
  
  private init() {}
  
  public var id: Int = 0
  public var type: ThemeType = ThemeType.light
  public var appearance: NSAppearance.Name = .vibrantLight
  public var syntax: String = "paraiso-light" {
    willSet(newSyntax) {
      defaults.setValue(newSyntax, forKey: "syntax")
    }
  }
  
}

let theme = Theme.sharedInstance
