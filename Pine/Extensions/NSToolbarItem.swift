//
//  NSToolbarItem.swift
//  Pine
//
//  Created by Luka Kerr on 19/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSToolbarItem.Identifier {

  static let h1 = NSToolbarItem.Identifier("\(IDENTIFIER).h1")
  static let h2 = NSToolbarItem.Identifier("\(IDENTIFIER).h2")
  static let h3 = NSToolbarItem.Identifier("\(IDENTIFIER).h3")

  static let bold = NSToolbarItem.Identifier("\(IDENTIFIER).bold")
  static let italic = NSToolbarItem.Identifier("\(IDENTIFIER).italic")

  static let code = NSToolbarItem.Identifier("\(IDENTIFIER).code")
  static let math = NSToolbarItem.Identifier("\(IDENTIFIER).math")
  static let image = NSToolbarItem.Identifier("\(IDENTIFIER).image")

}
