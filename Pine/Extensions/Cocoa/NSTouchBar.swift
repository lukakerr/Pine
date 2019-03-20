//
//  NSTouchBar.swift
//  Pine
//
//  Created by Luka Kerr on 23/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

let IDENTIFIER = "io.github.lukakerr"

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {

  static let h1 = NSTouchBarItem.Identifier("\(IDENTIFIER).h1")
  static let h2 = NSTouchBarItem.Identifier("\(IDENTIFIER).h2")
  static let h3 = NSTouchBarItem.Identifier("\(IDENTIFIER).h3")

  static let bold = NSTouchBarItem.Identifier("\(IDENTIFIER).bold")
  static let italic = NSTouchBarItem.Identifier("\(IDENTIFIER).italic")

  static let code = NSTouchBarItem.Identifier("\(IDENTIFIER).code")
  static let math = NSTouchBarItem.Identifier("\(IDENTIFIER).math")
  static let image = NSTouchBarItem.Identifier("\(IDENTIFIER).image")

}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {

  static let editorBar = NSTouchBar.CustomizationIdentifier("\(IDENTIFIER).editorBar")

}
