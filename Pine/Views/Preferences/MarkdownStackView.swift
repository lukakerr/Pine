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
    "GitHub Emoji's": .markdownEmojis,
    "Tables": .markdownTables,
    "Autolink URL's": .markdownAutolink,
    "GitHub @ Mentions": .markdownMentions,
    "Footnotes": .markdownFootnotes,
    "Checkboxes": .markdownCheckboxes,
    "WikiLinks": .markdownWikilinks,
    "Strikethrough": .markdownStrikethrough
  ]

  private let behaviorMap: BoolPreferenceMap = [
    "Auto pair syntax": .autoPairSyntax,
    "Enable spellcheck": .spellcheckEnabled
  ]

  private let autocompleteMap: BoolPreferenceMap = [
    "HTML": .htmlAutocomplete,
    "LaTeX": .latexAutocomplete,
    "Markdown": .markdownAutocomplete
  ]

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    view.addBooleanArea(
      target: self,
      using: behaviorMap,
      selector: #selector(behaviorMapPreferenceChanged)
    )

    return view
  }

  private func getAutocompleteArea() -> NSStackView {
    let view = PreferencesStackView(name: "Autocomplete:")

    view.addBooleanArea(
      target: self,
      using: autocompleteMap,
      selector: #selector(autocompletePreferenceChanged)
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
      getAutocompleteArea(),
      getExtensionsArea(),
      getDefaultApplicationArea()
    ]
  }

  // MARK: - Behavior preference actions

  @objc func behaviorMapPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(behaviorMap, key: sender.title, value: sender.value)
  }

  // MARK: - Autocomplete preference actions

  @objc func autocompletePreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(autocompleteMap, key: sender.title, value: sender.value)
  }

  // MARK: - Markdown extension preference actions

  @objc func extensionPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(extensionsMap, key: sender.title, value: sender.value)
  }

  // MARK: - Default application preference actions

  @objc func setDefaultApplication(_ sender: NSButton) {
    Utils.setDefaultApplication()
  }

}
