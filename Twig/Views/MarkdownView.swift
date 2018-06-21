//
//  MarkdownView.swift
//  Twig
//
//  Created by Luka Kerr on 21/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class MarkdownView: NSView {
  
  override func updateLayer() {
    updateUI()
  }

  // TODO: there is a catch 22 with having custom themes and supporting
  // mojave dark mode. updateLayer() only gets called if the apps appearance hasn't
  // been changed, but if we don't change the appearance then the titlebar text
  // color won't match the user selected theme. Need a way to listen for dark mode
  // being switched on/off that triggers no matter what the apps appearance is
  private func updateUI() {
    guard let bg = theme.background else { return }
    let appearance = NSApp.effectiveAppearance.name
    
    self.window?.titlebarAppearsTransparent = preferences.modernTitlebar
    
    if appearance == .darkAqua || bg.isDark {
      theme.code = bg.lighter
      theme.text = .white
      
      // using dark mode, so remove theme based appearance
      if appearance == .darkAqua {
        self.window?.backgroundColor = nil
      } else {
        self.window?.appearance = NSAppearance(named: .darkAqua)
        self.window?.backgroundColor = bg
      }
    } else {
      theme.code = bg.darker
      theme.text = .black
      self.window?.appearance = NSAppearance(named: .aqua)
      self.window?.backgroundColor = bg
    }

    NotificationCenter.send("appearanceChanged")
  }
  
}
