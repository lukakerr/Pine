//
//  MarkdownView.swift
//  Pine
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
    self.window?.titlebarAppearsTransparent = preferences[.modernTitlebar]

    // Not using system appearance, so stick with theme
    if !preferences[.useSystemAppearance] {
      if let bg = theme.highlightr.theme.themeBackgroundColor {
        setThemeAndWindowAppearance(
          isDark: bg.isDark,
          color: bg
        )
      }
    } else {
      setThemeAndWindowAppearance(
        isDark: NSAppearance.Name.current == .dark,
        color: NSColor.textBackgroundColor
      )

      window?.appearance = nil
    }

    NotificationCenter.send(.appearanceChanged)
  }

  private func setThemeAndWindowAppearance(isDark: Bool, color: NSColor) {
    if isDark {
      theme.code = color.lighter
      theme.text = .white
      window?.appearance = NSAppearance(named: .dark)
    } else {
      theme.code = color.darker
      theme.text = .black
      window?.appearance = NSAppearance(named: .light)
    }

    theme.background = color
    window?.backgroundColor = color
  }

}
