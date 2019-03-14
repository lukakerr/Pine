//
//  PreferencesWindowController.swift
//  Pine
//
//  Created by Luka Kerr on 1/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

let PREFERENCES_AUTOSAVE_NAME = "PreferencesWindow"

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

  override func windowDidLoad() {
    super.windowDidLoad()

    self.window?.setFrameAutosaveName(PREFERENCES_AUTOSAVE_NAME)
  }

}
