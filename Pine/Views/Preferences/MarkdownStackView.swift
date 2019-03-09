//
//  MarkdownStackView.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class MarkdownStackView: NSStackView, PreferenceStackView {

  private let extensionsMap: BoolPreferenceMap = [
    "GitHub Emoji's": Preference.markdownEmojis,
    "Tables": Preference.markdownTables,
    "Autolink URL's": Preference.markdownAutolink,
    "GitHub @ Mentions": Preference.markdownMentions,
    "Footnotes": Preference.markdownFootnotes,
    "Checkboxes": Preference.markdownCheckboxes,
    "Strikethrough": Preference.markdownStrikethrough
  ]

  private let behaviourMap: BoolPreferenceMap = [
    "Auto pair syntax": Preference.autoPairSyntax,
    "Enable spellcheck": Preference.spellcheckEnabled
  ]

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    view.addBooleanArea(
      target: self,
      using: behaviourMap,
      selector: #selector(behaviourPreferenceChanged)
    )

    return view
  }

  private func getExtensionsArea() -> NSStackView {
    let view = PreferencesStackView(name: "Extensions:")

    view.addBooleanArea(
      target: self,
      using: extensionsMap,
      selector: #selector(extensionPreferenceChanged)
    )

    return view
  }

  private func getDefaultApplicationArea() -> NSStackView {
    let view = PreferencesStackView(name: "Default Application:")

    let setDefaultButton = PreferencesRoundedButton()
    setDefaultButton.title = "Set Pine as the Default Application"
    setDefaultButton.target = self
    setDefaultButton.action = #selector(setDefaultApplication)

    view.addPreferences([
      setDefaultButton
    ])

    return view
  }

  public func getViews() -> [NSView] {
    return [
      getBehaviorArea(),
      getExtensionsArea(),
      getDefaultApplicationArea()
    ]
  }

  // MARK: - Behavior preference actions

  @objc func behaviourPreferenceChanged(_ sender: NSButton) {
    if let ext = behaviourMap[sender.title] {
      preferences[ext] = sender.value
      NotificationCenter.send(.preferencesChanged)
    }
  }

  // MARK: - Markdown extension preference actions

  @objc func extensionPreferenceChanged(_ sender: NSButton) {
    if let ext = extensionsMap[sender.title] {
      preferences[ext] = sender.value
      NotificationCenter.send(.preferencesChanged)
    }
  }

  // MARK: - Default application preference actions

  @objc func setDefaultApplication(_ sender: NSButton) {
    Utils.setDefaultApplication()
  }

}
