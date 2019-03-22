//
//  DocumentStackView.swift
//  Pine
//
//  Created by Luka Kerr on 1/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class DocumentStackView: NSStackView, PreferenceStackView {

  private let behaviourMap: BoolPreferenceMap = [
    "Autosave document": .autosaveDocument,
    "Open new document on startup": .openNewDocumentOnStartup
  ]

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    view.addBooleanArea(
      target: self,
      using: behaviourMap,
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
    preferences.setFromBoolMap(behaviourMap, key: sender.title, value: sender.value)
  }

}
