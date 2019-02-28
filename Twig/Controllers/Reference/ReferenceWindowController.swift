//
//  ReferenceWindowController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let REFERENCE_AUTOSAVE_NAME = "ReferenceWindow"

class ReferenceWindowController: NSWindowController, NSWindowDelegate {

  override func windowDidLoad() {
    super.windowDidLoad()

    updateUI()

    self.window?.setFrameAutosaveName(REFERENCE_AUTOSAVE_NAME)

    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(updateUI))
  }

  @objc private func updateUI() {
    if #available(OSX 10.14, *) {
      if NSApp.effectiveAppearance.name == .darkAqua { return }
    }

    window?.backgroundColor = theme.background

    if theme.background.isDark {
      window?.appearance = NSAppearance(named: .dark)
    } else {
      window?.appearance = NSAppearance(named: .light)
    }
  }

}
