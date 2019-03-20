//
//  EditorStackView.swift
//  Pine
//
//  Created by Luka Kerr on 20/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class EditorStackView: NSStackView, PreferenceStackView, NSFontChanging {

  private let appearanceMap: BoolPreferenceMap = [
    "Show invisibles": Preference.showInvisibles
  ]

  private func getAppearanceArea() -> NSStackView {
    let view = PreferencesStackView(name: "Appearance:")

    view.addBooleanArea(
      target: self,
      using: appearanceMap,
      selector: #selector(appearancePreferenceChanged)
    )

    return view
  }

  private func getFontArea() -> NSStackView {
    let view = PreferencesStackView(name: "Font:")

    let button = PreferencesRoundedButton()
    button.title = "Change"
    button.target = self
    button.action = #selector(self.fontChanged)

    view.addPreferences([
      button
    ])

    return view
  }

  public func getViews() -> [NSView] {
    return [
      getAppearanceArea(),
      getFontArea()
    ]
  }

  // MARK: - Behavior preference actions

  @objc func appearancePreferenceChanged(_ sender: NSButton) {
    if let ext = appearanceMap[sender.title] {
      preferences[ext] = sender.value
      NotificationCenter.send(.preferencesChanged)
    }
  }

  // MARK: - Font preference actions

  @objc func fontChanged(_ sender: NSButton) {
    NSFontManager.shared.target = self

    let fontPanel = NSFontPanel.shared
    fontPanel.setPanelFont(preferences.font, isMultiple: false)
    fontPanel.makeKeyAndOrderFront(sender)
  }

  func changeFont(_ sender: NSFontManager?) {
    if let fontManager = sender {
      preferences.font = fontManager.convert(preferences.font)
      NotificationCenter.send(.preferencesChanged)
    }
  }

}
