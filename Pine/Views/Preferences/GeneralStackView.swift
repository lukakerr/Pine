//
//  GeneralStackView.swift
//  Pine
//
//  Created by Luka Kerr on 26/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class GeneralStackView: NSStackView, PreferenceStackView {

  private let behaviorMap: BoolPreferenceMap = [
    "Show editor on startup": .showEditorOnStartup,
    "Show preview on startup": .showPreviewOnStartup,
    "Open new document on startup": .openNewDocumentOnStartup,
    "Terminate after last window closed": .terminateAfterLastWindowClosed
  ]

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    view.addBooleanArea(
      target: self,
      using: behaviorMap,
      selector: #selector(behaviorPreferenceChanged)
    )

    return view
  }

  public func getViews() -> [NSView] {
    return [
      getBehaviorArea()
    ]
  }

  // MARK: - Behavior preference actions

  @objc func behaviorPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(behaviorMap, key: sender.title, value: sender.value)
  }

}
