//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
  }
  
  func windowDidBecomeKey(_ notification: Notification) {
    // Handles when the window comes back into focus but hasn't changed
    if NSApplication.shared.keyWindow != self.window {
      return
    }
    
    var windowIndex = 0
    let windows = NSApplication.shared.windows.filter { $0.isVisible }

    for (index, window) in windows.enumerated() {
      if window == self.window {
        windowIndex = index
      }
    }
    
    selectedIndex = windowIndex
    
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "selectedIndexDidChange"),
      object: nil
    )
  }

}
