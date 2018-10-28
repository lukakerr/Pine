//
//  NSView.swift
//  Twig
//
//  Created by Francesco on 28/10/2018.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSView {
    func setBackgroundColor(_ color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
}
