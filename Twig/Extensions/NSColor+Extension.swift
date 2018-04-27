//
//  NSColor+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSColor {
  
  var isDark: Bool {
    if let color = self.usingColorSpace(.sRGB) {
      let red = color.redComponent
      let green = color.greenComponent
      let blue = color.blueComponent
      
      // Formula taken from https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
      let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
      return brightness < 0.5
    }
    return false
  }
  
  var hex: String {
    if let color = self.usingColorSpace(.sRGB) {
      let red = Int(round(color.redComponent * 0xFF))
      let green = Int(round(color.greenComponent * 0xFF))
      let blue = Int(round(color.blueComponent * 0xFF))
      
      let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
      return hexString as String
    }
    return "#FFF"
  }
  
  var lighter: NSColor {
    if let color = self.usingColorSpace(.sRGB) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      
      color.getRed(&r, green: &g, blue: &b, alpha: &a)
      return NSColor(red: max(r + 0.1, 0.0), green: max(g + 0.1, 0.0), blue: max(b + 0.1, 0.0), alpha: a)
    }
    return self
  }
  
  var darker: NSColor {
    if let color = self.usingColorSpace(.sRGB) {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      
      color.getRed(&r, green: &g, blue: &b, alpha: &a)
      return NSColor(red: max(r - 0.1, 0.0), green: max(g - 0.1, 0.0), blue: max(b - 0.1, 0.0), alpha: a)
    }
    return self
  }
  
}
