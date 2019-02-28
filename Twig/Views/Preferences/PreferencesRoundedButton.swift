//
//  PreferencesRoundedButton.swift
//  Twig
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesRoundedButton: NSButton {

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    self.bezelStyle = .rounded
    self.setButtonType(.momentaryPushIn)
  }

}
