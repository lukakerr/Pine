//
//  NSAppearance+Extension.swift
//  Pine
//
//  Created by Luka Kerr on 2/7/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSAppearance.Name {

  static var current: NSAppearance.Name {
    if !preferences[Preference.useSystemAppearance] {
      return theme.background.isDark ? .dark : .light
    }

    if #available(OSX 10.14, *) {
      return NSApp.effectiveAppearance.name == .dark ? .dark : .light
    }

    let aWindow = NSApp.windows.first

    return aWindow?.appearance?.name == .dark ? .dark : .light
  }

  static var dark: NSAppearance.Name {
    if #available(OSX 10.14, *) {
      return .darkAqua
    }

    return .vibrantDark
  }

  static let light: NSAppearance.Name = .aqua
}
