//
//  PineSplitView.swift
//  Pine
//
//  Created by Luka Kerr on 14/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class PineSplitView: NSSplitView {

  override func viewDidMoveToWindow() {
    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(updateUI))
  }

  override func viewWillDraw() {
    self.updateUI()
  }

  @objc private func updateUI() {
    // when isVertical is true, split views drawn as V | V
    isVertical = preferences[Preference.verticalSplitView]
  }

}
