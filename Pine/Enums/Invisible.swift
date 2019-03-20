//
//  Invisible.swift
//  Pine
//
//  Created by Luka Kerr on 20/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

enum Invisible {

  case space
  case tab
  case newLine

  init?(char: Character) {
    switch char {
    case " ":
      self = .space
    case "\t":
      self = .tab
    case "\n":
      self = .newLine
    default:
      return nil
    }
  }

  func getChar(isRtl: Bool) -> String {
    switch self {
    case .space:
      return "·"
    case .tab:
      return isRtl ? "◂" : "‣"
    case .newLine:
      return "¬"
    }
  }

}
