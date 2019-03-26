//
//  PreferencesSwitchButton.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesSwitchButton: NSButton {

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    self.setButtonType(.switch)
    self.font = NSFont.systemFont(ofSize: 14)
  }

}
