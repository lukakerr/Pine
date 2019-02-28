//
//  MarkdownStackView.swift
//  Twig
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class MarkdownStackView: NSStackView, PreferenceStackView {

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    let autoPairSyntaxButton = PreferencesSwitchButton()
    autoPairSyntaxButton.title = "Auto pair syntax"
    autoPairSyntaxButton.target = self
    autoPairSyntaxButton.action = #selector(autoPairSyntaxChanged)
    autoPairSyntaxButton.state = preferences.autoPairSyntax.state

    let spellcheckEnabledButton = PreferencesSwitchButton()
    spellcheckEnabledButton.title = "Enable spellcheck"
    spellcheckEnabledButton.target = self
    spellcheckEnabledButton.action = #selector(spellcheckEnabledChanged)
    spellcheckEnabledButton.state = preferences.spellcheckEnabled.state

    view.addPreferences([
      autoPairSyntaxButton,
      spellcheckEnabledButton
    ])

    return view
  }

  public func getViews() -> [NSView] {
    return [
      getBehaviorArea()
    ]
  }

  // MARK: - Behavior preference actions

  @objc func autoPairSyntaxChanged(_ sender: NSButton) {
    preferences.autoPairSyntax = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func spellcheckEnabledChanged(_ sender: NSButton) {
    preferences.spellcheckEnabled = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

}
