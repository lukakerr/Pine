//
//  UIStackView.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class UIStackView: NSStackView, PreferenceStackView, NSFontChanging {

  private let appearanceMap: BoolPreferenceMap = [
    "Use system appearance": Preference.useSystemAppearance
  ]

  private let windowMap: BoolPreferenceMap = [
    "Show sidebar": Preference.showSidebar,
    "Modern titlebar": Preference.modernTitlebar,
    "Vertical split": Preference.verticalSplitView,
    "Use theme color for sidebar": Preference.useThemeColorForSidebar
  ]

  private let behaviorMap: BoolPreferenceMap = [
    "Show preview on startup": Preference.showPreviewOnStartup
  ]

  private func getAppearanceArea() -> NSStackView {
    let view = PreferencesStackView(name: "Appearance:")

    let syntaxDropdown = NSPopUpButton()
    syntaxDropdown.target = self
    syntaxDropdown.action = #selector(self.syntaxChanged)

    SyntaxThemes.ThemeList.forEach { syntaxDropdown.addItem(withTitle: $0) }

    syntaxDropdown.selectItem(withTitle: theme.syntax)

    let revealThemesButton = PreferencesRoundedButton()
    revealThemesButton.title = "Reveal Themes"
    revealThemesButton.target = self
    revealThemesButton.action = #selector(revealThemes)

    view.addPreferences([
      syntaxDropdown,
      revealThemesButton,
    ])

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
      getFontArea(),
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

  @objc func revealThemes(_ sender: NSButton) {
    if let folder =  FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let styles = folder.appendingPathComponent("highlight-js/styles")
      NSWorkspace.shared.activateFileViewerSelecting([styles])
    }
  }

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

  // MARK: - Window preference actions

  @objc func windowPreferenceChanged(_ sender: NSButton) {
    if let ext = windowMap[sender.title] {
      preferences[ext] = sender.value
      NotificationCenter.send(.preferencesChanged)
    }
  }

  // MARK: - Behavior preference actions

  @objc func behaviorPreferenceChanged(_ sender: NSButton) {
    if let ext = behaviorMap[sender.title] {
      preferences[ext] = sender.value
      NotificationCenter.send(.preferencesChanged)
    }
  }

}
