//
//  PreferencesWindowController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    if let window = window {
      window.appearance = NSAppearance(named: theme.appearance)
      window.isOpaque = false
      window.invalidateShadow()
      window.center()
      window.makeKeyAndOrderFront(nil)
    }
    
    NSApp.activate(ignoringOtherApps: true)
  }
  
}
