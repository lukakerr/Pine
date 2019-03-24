//
//  PreviewStackView.swift
//  Pine
//
//  Created by Luka Kerr on 24/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class PreviewStackView: NSStackView, PreferenceStackView {

  private func getPluginsArea() -> NSStackView {
    let view = PreferencesStackView(name: "Plugins:")

    let revealPluginsButton = PreferencesRoundedButton()
    revealPluginsButton.title = "Reveal Plugins"
    revealPluginsButton.target = self
    revealPluginsButton.action = #selector(revealPlugins)

    view.addPreferences([
      revealPluginsButton
    ])

    return view
  }

  public func getViews() -> [NSView] {
    return [
      getPluginsArea()
    ]
  }

  // MARK: - Plugins preference actions

  @objc func revealPlugins(_ sender: NSButton) {
    if let folder =  Utils.getApplicationSupportDirectory(for: .plugins) {
      NSWorkspace.shared.activateFileViewerSelecting([folder])
    }
  }

}

