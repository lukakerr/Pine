//
//  NSView.swift
//  Pine
//
//  Created by Luka Kerr on 10/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSView {

  public func setBackgroundColor(_ color: NSColor) {
    wantsLayer = true
    layer?.backgroundColor = color.cgColor
  }

}
