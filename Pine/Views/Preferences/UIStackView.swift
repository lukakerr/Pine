//
//  UIStackView.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class UIStackView: NSStackView, PreferenceStackView {

  private let appearanceMap: BoolPreferenceMap = [
    "Use system appearance": .useSystemAppearance
  ]

  private let windowMap: BoolPreferenceMap = [
    "Show toolbar": .showToolbar,
    "Show sidebar": .showSidebar,
    "Modern titlebar": .modernTitlebar,
    "Vertical split": .verticalSplitView,
    "Use theme color for sidebar": .useThemeColorForSidebar
  ]

  private let behaviorMap: BoolPreferenceMap = [
    "Show preview on startup": .showPreviewOnStartup,
    "Sync editor and preview": .syncEditorAndPreview
  ]

  private func getAppearanceArea() -> NSStackView {
    let view = PreferencesStackView(name: "Appearance:")

    let syntaxDropdown = NSPopUpButton()
    syntaxDropdown.target = self
    syntaxDropdown.action = #selector(self.syntaxChanged)

    SyntaxThemes.ThemeList.forEach { syntaxDropdown.addItem(withTitle: $0) }

    syntaxDropdown.selectItem(withTitle: theme.syntax)

    view.addPreferences([
      syntaxDropdown
    ])

    view.addBooleanArea(
      target: self,
      using: appearanceMap,
      selector: #selector(appearancePreferenceChanged)
    )

    return view
  }

  private func getWindowArea() -> NSStackView {
    let view = PreferencesStackView(name: "Window:")

    view.addBooleanArea(
      target: self,
      using: windowMap,
      selector: #selector(windowPreferenceChanged)
    )

    return view
  }

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
      getAppearanceArea(),
      getWindowArea(),
      getBehaviorArea()
    ]
  }

  // MARK: - Appearance preference actions

  @objc func syntaxChanged(_ sender: NSPopUpButton) {
    theme.setTheme(to: sender.title)
    html.updateSyntaxTheme()
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func appearancePreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(appearanceMap, key: sender.title, value: sender.value)
  }

  // MARK: - Window preference actions

  @objc func windowPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(windowMap, key: sender.title, value: sender.value)
  }

  // MARK: - Behavior preference actions

  @objc func behaviorPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(behaviorMap, key: sender.title, value: sender.value)
  }

}
