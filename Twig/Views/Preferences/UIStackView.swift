//
//  UIStackView.swift
//  Twig
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class UIStackView: NSStackView, PreferenceStackView, NSFontChanging {

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

    let useSystemAppearanceButton = PreferencesSwitchButton()
    useSystemAppearanceButton.title = "Use system appearance"
    useSystemAppearanceButton.target = self
    useSystemAppearanceButton.action = #selector(useSystemAppearanceChanged)
    useSystemAppearanceButton.state = preferences.useSystemAppearance.state

    view.addPreferences([
      syntaxDropdown,
      revealThemesButton,
      useSystemAppearanceButton
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

  private func getWindowArea() -> NSStackView {
    let view = PreferencesStackView(name: "Window:")

    let modernTitlebarButton = PreferencesSwitchButton()
    modernTitlebarButton.title = "Modern titlebar"
    modernTitlebarButton.target = self
    modernTitlebarButton.action = #selector(modernTitlebarChanged)
    modernTitlebarButton.state = preferences.modernTitlebar.state

    let verticalSplitButton = PreferencesSwitchButton()
    verticalSplitButton.title = "Vertical split"
    verticalSplitButton.target = self
    verticalSplitButton.action = #selector(verticalSplitViewChanged)
    verticalSplitButton.state = preferences.verticalSplitView.state

    let showSidebarButton = PreferencesSwitchButton()
    showSidebarButton.title = "Show sidebar"
    showSidebarButton.target = self
    showSidebarButton.action = #selector(showSidebarChanged)
    showSidebarButton.state = preferences.showSidebar.state

    let sidebarThemeColorButton = PreferencesSwitchButton()
    sidebarThemeColorButton.title = "Use theme color for sidebar"
    sidebarThemeColorButton.target = self
    sidebarThemeColorButton.action = #selector(useThemeColorForSidebarChanged)
    sidebarThemeColorButton.state = preferences.useThemeColorForSidebar.state

    view.addPreferences([
      modernTitlebarButton,
      verticalSplitButton,
      showSidebarButton,
      sidebarThemeColorButton
    ])

    return view
  }

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    let previewOnStartupButton = PreferencesSwitchButton()
    previewOnStartupButton.title = "Show preview on startup"
    previewOnStartupButton.target = self
    previewOnStartupButton.action = #selector(showPreviewOnStartupChanged)
    previewOnStartupButton.state = preferences.showPreviewOnStartup.state

    view.addPreferences([
      previewOnStartupButton
    ])

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
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func revealThemes(_ sender: NSButton) {
    if let folder =  FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let styles = folder.appendingPathComponent("highlight-js/styles")
      NSWorkspace.shared.activateFileViewerSelecting([styles])
    }
  }

  @objc func useSystemAppearanceChanged(_ sender: NSButton) {
    preferences.useSystemAppearance = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
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

  @objc func modernTitlebarChanged(_ sender: NSButton) {
    preferences.modernTitlebar = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func verticalSplitViewChanged(_ sender: NSButton) {
    preferences.verticalSplitView = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func showSidebarChanged(_ sender: NSButton) {
    preferences.showSidebar = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func useThemeColorForSidebarChanged(_ sender: NSButton) {
    preferences.useThemeColorForSidebar = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

  // MARK: Behavior preference actions

  @objc func showPreviewOnStartupChanged(_ sender: NSButton) {
    preferences.showPreviewOnStartup = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

}
