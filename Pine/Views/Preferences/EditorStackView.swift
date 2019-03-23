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
    "Show invisibles": .showInvisibles
  ]

  private let behaviourMap: BoolPreferenceMap = [
    "Scroll past end": .scrollPastEnd
  ]

  private let writingDirectionMap: [String: NSWritingDirection] = [
    "Default": NSWritingDirection.natural,
    "Left to Right": NSWritingDirection.leftToRight,
    "Right to Left": NSWritingDirection.rightToLeft
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

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    view.addBooleanArea(
      target: self,
      using: behaviourMap,
      selector: #selector(behaviorPreferenceChanged)
    )

    return view
  }

  private func getWritingDirectionArea() -> NSStackView {
    let view = PreferencesStackView(name: "Writing Direction:")

    let writingDirectionDropdown = NSPopUpButton()
    writingDirectionDropdown.target = self
    writingDirectionDropdown.action = #selector(self.writingDirectionChanged)

    writingDirectionMap.keys.sorted().forEach { writingDirectionDropdown.addItem(withTitle: $0) }

    if let selected = writingDirectionMap.first(where: { $1 == preferences.writingDirection })?.key {
      writingDirectionDropdown.selectItem(withTitle: selected)
    }

    view.addPreferences([
      writingDirectionDropdown
    ])

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
      getBehaviorArea(),
      getFontArea(),
      getWritingDirectionArea()
    ]
  }

  // MARK: - Appearance preference actions

  @objc func appearancePreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(appearanceMap, key: sender.title, value: sender.value)
  }

  // MARK: - Behavior preference actions

  @objc func behaviorPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(behaviourMap, key: sender.title, value: sender.value)
  }

  // MARK: Writing direction preference actions

  @objc func writingDirectionChanged(_ sender: NSPopUpButton) {
    if let direction = writingDirectionMap[sender.title] {
      preferences.writingDirection = direction
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
