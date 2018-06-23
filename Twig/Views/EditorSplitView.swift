//
//  EditorSplitView.swift
//  Twig
//
//  Created by Luka Kerr on 14/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class EditorSplitView: NSSplitView {

  override func viewWillDraw() {
    // when isVertical is true, split views drawn as V | V
    self.isVertical = preferences.verticalSplitView
  }

}
