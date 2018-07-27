//
//  NSMutableAttributedString+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSMutableAttributedString {

  public func withAttribute(_ attribute: NSAttributedString.Key, _ value: Any, _ range: NSRange? = nil) {
    return addAttribute(
      attribute,
      value: value,
      range: range ?? NSRange(location: 0, length: length)
    )
  }

  public func withColor(_ color: NSColor, at: NSRange? = nil) {
    return withAttribute(NSAttributedString.Key.foregroundColor, color, at)
  }

  public func withBackgroundColor(_ color: NSColor, at: NSRange? = nil) {
    return withAttribute(NSAttributedString.Key.backgroundColor, color, at)
  }

  public func withFont(_ font: NSFont, at: NSRange? = nil) {
    return withAttribute(NSAttributedString.Key.font, font, at)
  }

}
