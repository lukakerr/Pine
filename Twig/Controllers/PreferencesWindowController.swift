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
    
    updateUI()
    
    NotificationCenter.receive("preferencesChanged", instance: self, selector: #selector(self.updateUI))

    window?.center()
    window?.makeKeyAndOrderFront(nil)
  }
  
  @objc private func updateUI() {
    if NSApp.effectiveAppearance.name == .darkAqua { return }
    if let bg = theme.background {
      window?.backgroundColor = bg
      if bg.isDark {
        window?.appearance = NSAppearance(named: .darkAqua)
      } else {
        window?.appearance = NSAppearance(named: .aqua)
      }
    }
  }
  
}
