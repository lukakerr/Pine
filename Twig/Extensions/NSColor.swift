//
//  NSColor+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSColor {

  private func getRGBComponents(_ color: NSColor) -> (CGFloat, CGFloat, CGFloat) {
    if let color = color.usingColorSpace(.sRGB) {
      return (
        color.redComponent,
        color.greenComponent,
        color.blueComponent
      )
    }
    return (0, 0, 0)
  }

  var isDark: Bool {
    let (r, g, b) = getRGBComponents(self)

    // Formula taken from https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
    let brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000
    return brightness < 0.5
  }

  var hex: String {
    let (r, g, b) = getRGBComponents(self)
    let red = Int(round(r * 0xFF))
    let green = Int(round(g * 0xFF))
    let blue = Int(round(b * 0xFF))
    return NSString(format: "#%02X%02X%02X", red, green, blue) as String
  }

  var lighter: NSColor {
    let (r, g, b) = getRGBComponents(self)
    return NSColor(red: min(r + 0.1, 1.0), green: min(g + 0.1, 1.0), blue: min(b + 0.1, 1.0), alpha: 0)
  }

  var darker: NSColor {
    let (r, g, b) = getRGBComponents(self)
    return NSColor(red: max(r - 0.025, 0.0), green: max(g - 0.025, 0.0), blue: max(b - 0.025, 0.0), alpha: 0)
  }

}
