//
//  CTLine.swift
//  Pine
//
//  Created by Luka Kerr on 20/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

extension CTLine {

  class func create(string: String, color: NSColor, font: NSFont) -> CTLine {
    let attrString = NSAttributedString(
      string: string,
      attributes: [.foregroundColor: color, .font: font]
    )

    return CTLineCreateWithAttributedString(attrString)
  }

  public var bounds: CGRect {
    return CTLineGetBoundsWithOptions(self, [])
  }

}
