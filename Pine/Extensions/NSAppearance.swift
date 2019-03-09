//
//  NSAppearance+Extension.swift
//  Pine
//
//  Created by Luka Kerr on 2/7/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSAppearance.Name {

  static var dark: NSAppearance.Name {
    if #available(OSX 10.14, *) {
      return .darkAqua
    }

    return .vibrantDark
  }

  static let light: NSAppearance.Name = .aqua
}
