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
  
  private init() {}
  
  // Default theme is github-gist
  public var syntax: String = "github-gist" {
    willSet(newSyntax) {
      defaults.setValue(newSyntax, forKey: "syntax")
    }
  }
  public var background: String = "#FFF"
  public var code: String = "#FFF"
  public var text: String = "#FFF"
  
}

let theme = Theme.sharedInstance
