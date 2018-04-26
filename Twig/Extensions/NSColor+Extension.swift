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
  
}
