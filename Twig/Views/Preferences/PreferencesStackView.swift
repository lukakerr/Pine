//
//  PreferencesStackView.swift
//  Twig
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

protocol PreferenceStackView {

  func getViews() -> [NSView]

}

class PreferencesStackView: NSStackView {

  private var name: String!

  init(name: String) {
    super.init(frame: NSZeroRect)

    self.name = name
    self.spacing = 0.0
    self.alignment = .left
    self.orientation = .horizontal
    self.distribution = .fillEqually
    self.edgeInsets = NSEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }

  public func addPreferences(_ views: [NSView]) {
    let title = NSTextField()
    title.isEditable = false
    title.isBezeled = false
    title.isSelectable = false
    title.focusRingType = .none
    title.drawsBackground = false
    title.alignment = .left
    title.font = NSFont.systemFont(ofSize: 14, weight: .bold)
    title.stringValue = self.name

    let titleMinWidthConstraint = NSLayoutConstraint(
      item: title,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: 150
    )

    self.addConstraint(titleMinWidthConstraint)

    let prefView = NSStackView()
    prefView.spacing = 10.0
    prefView.alignment = .left
    prefView.orientation = .vertical
    prefView.distribution = .fillEqually

    for v in views {
      prefView.addArrangedSubview(v)
    }

    self.addArrangedSubview(title)
    self.addArrangedSubview(prefView)
  }

}
