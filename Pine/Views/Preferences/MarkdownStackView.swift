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
    "WikiLinks": Preference.markdownWikilinks,
    "Strikethrough": Preference.markdownStrikethrough
  ]

  private let behaviourMap: BoolPreferenceMap = [
    "Auto pair syntax": Preference.autoPairSyntax,
    "Enable spellcheck": Preference.spellcheckEnabled
  ]

  private let autocompleteMap: BoolPreferenceMap = [
    "HTML": Preference.htmlAutocomplete,
    "LaTeX": Preference.latexAutocomplete,
    "Markdown": Preference.markdownAutocomplete
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

  @objc func behaviourPreferenceChanged(_ sender: NSButton) {
    preferences.setFromBoolMap(behaviourMap, key: sender.title, value: sender.value)
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
