//
//  PreferencesStackView.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

protocol PreferenceStackView {

  /// Get a list of views to be used for each section in the preference category
  func getViews() -> [NSView]

}

typealias BoolPreferenceMap = [String: PreferenceKey<Bool>]

class PreferencesStackView: NSStackView {

  private var name: String!
  private var hasSection: Bool!
  private var prefView: NSStackView!

  init(name: String) {
    super.init(frame: NSZeroRect)

    self.name = name
    self.hasSection = false
    self.spacing = 0.0
    self.alignment = .left
    self.orientation = .horizontal
    self.distribution = .fillEqually
    self.edgeInsets = NSEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    self.prefView = NSStackView()
    self.prefView.spacing = 10.0
    self.prefView.alignment = .left
    self.prefView.orientation = .vertical
    self.prefView.distribution = .fillEqually
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }

  public func addPreferences(_ views: [NSView]) {
    if hasSection {
      for v in views {
        prefView.addArrangedSubview(v)
      }

      return
    } else {
      hasSection = true
    }

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

    for v in views {
      prefView.addArrangedSubview(v)
    }

    self.addArrangedSubview(title)
    self.addArrangedSubview(prefView)
  }

  public func addBooleanArea(
    target: NSObject,
    using map: BoolPreferenceMap,
    selector: Selector
  ) {
    var preferenceViews: [NSView] = []

    map
      .sorted { $0.0.count < $1.0.count }
      .forEach { (title, ext) in
        let btn = PreferencesSwitchButton()
        btn.title = title
        btn.target = target
        btn.action = selector
        btn.state = preferences[ext].state

        preferenceViews.append(btn)
    }

    self.addPreferences(preferenceViews)
  }

}
