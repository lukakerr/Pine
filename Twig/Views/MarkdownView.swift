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

  private func updateUI() {
    let bg = theme.background
    let appearance = NSApp.effectiveAppearance.name

    self.window?.titlebarAppearsTransparent = preferences.modernTitlebar

    if appearance == .darkAqua || bg.isDark {
      theme.code = bg.lighter
      theme.text = .white

      // using dark mode, so remove theme based appearance
      if appearance == .darkAqua {
        self.window?.backgroundColor = nil
      } else {
        if !preferences.useSystemAppearance {
          self.window?.appearance = NSAppearance(named: .darkAqua)
        }
        self.window?.backgroundColor = bg
      }
    } else {
      theme.code = bg.darker
      theme.text = .black
      if !preferences.useSystemAppearance {
        self.window?.appearance = NSAppearance(named: .aqua)
      }
      self.window?.backgroundColor = bg
    }

    // remove appearance so when dark/light mode changed, updateLayer() is called
    if preferences.useSystemAppearance {
      self.window?.appearance = nil
    }

    NotificationCenter.send(.appearanceChanged)
  }

}
