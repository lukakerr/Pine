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

    var appearance = window?.appearance?.name

    if #available(OSX 10.14, *) {
      appearance = NSApp.effectiveAppearance.name
    }

    self.window?.titlebarAppearsTransparent = preferences[Preference.modernTitlebar]

    if appearance == .dark || bg.isDark {
      theme.code = bg.lighter
      theme.text = .white

      // Using dark mode, so remove theme based appearance
      if appearance == .dark {
        window?.backgroundColor = nil
      } else {
        if !preferences[Preference.useSystemAppearance] {
          window?.appearance = NSAppearance(named: .dark)
        }
        window?.backgroundColor = bg
      }
    } else {
      theme.code = bg.darker
      theme.text = .black
      if !preferences[Preference.useSystemAppearance] {
        window?.appearance = NSAppearance(named: .aqua)
      }
      window?.backgroundColor = bg
    }

    // Remove appearance so when dark/light mode changed, updateLayer() is called
    if preferences[Preference.useSystemAppearance] {
      window?.appearance = nil
    }

    NotificationCenter.send(.appearanceChanged)
  }

}
