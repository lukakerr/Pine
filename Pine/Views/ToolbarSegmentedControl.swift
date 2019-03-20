//
//  ToolbarSegmentedControl.swift
//  Pine
//
//  Created by Luka Kerr on 21/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class ToolbarSegmentedControl: NSSegmentedControl {

  public var segments: [ToolbarItemInfo] = []

  init(segments: [ToolbarItemInfo]) {
    super.init(frame: .zero)

    self.segments = segments
    self.target = self
    self.segmentStyle = .texturedRounded
    self.trackingMode = .momentary
    self.segmentCount = segments.count
    self.action = #selector(segmentSelected)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  @IBAction func segmentSelected(_ sender: Any) {
    if let action = segments[selectedSegment].action {
      NSApp.sendAction(action, to: nil, from: nil)
    }
  }
}
