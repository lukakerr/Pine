//
//  DocumentStackView.swift
//  Twig
//
//  Created by Luka Kerr on 1/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class DocumentStackView: NSStackView, PreferenceStackView {

  private func getBehaviorArea() -> NSStackView {
    let view = PreferencesStackView(name: "Behavior:")

    let autosaveDocButton = PreferencesSwitchButton()
    autosaveDocButton.title = "Autosave document"
    autosaveDocButton.target = self
    autosaveDocButton.action = #selector(autosaveDocumentChanged)
    autosaveDocButton.state = preferences.autosaveDocument.state

    let newDocOnStartButton = PreferencesSwitchButton()
    newDocOnStartButton.title = "Open new document on startup"
    newDocOnStartButton.target = self
    newDocOnStartButton.action = #selector(openNewDocumentOnStartupChanged)
    newDocOnStartButton.state = preferences.openNewDocumentOnStartup.state

    view.addPreferences([
      autosaveDocButton,
      newDocOnStartButton
    ])

    return view
  }

  public func getViews() -> [NSView] {
    return [
      getBehaviorArea()
    ]
  }

  // MARK: - Behavior preference actions

  @objc func autosaveDocumentChanged(_ sender: NSButton) {
    preferences.autosaveDocument = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

  @objc func openNewDocumentOnStartupChanged(_ sender: NSButton) {
    preferences.openNewDocumentOnStartup = sender.state.rawValue.bool
    NotificationCenter.send(.preferencesChanged)
  }

}
