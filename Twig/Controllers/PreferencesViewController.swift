//
//  PreferencesViewController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController, NSFontChanging {

  @IBOutlet weak var syntaxDropdown: NSPopUpButton!
  @IBOutlet weak var showPreviewOnStartup: NSButton!
  @IBOutlet weak var openNewDocumentOnStartup: NSButton!
  @IBOutlet weak var autosaveDocument: NSButton!
  @IBOutlet weak var verticalSplitView: NSButton!
  @IBOutlet weak var modernTitlebar: NSButton!
  @IBOutlet weak var useSystemAppearance: NSButton!
  @IBOutlet weak var showSidebar: NSButton!
  @IBOutlet weak var enableSpellcheck: NSButton!
  @IBOutlet weak var useThemeColorForSidebar: NSButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    syntaxDropdown.removeAllItems()

    SyntaxThemes.ThemeList.forEach { syntaxDropdown.addItem(withTitle: $0) }

    syntaxDropdown.selectItem(withTitle: theme.syntax)

    showPreviewOnStartup.state = getState(preferences.showPreviewOnStartup)
    openNewDocumentOnStartup.state = getState(preferences.openNewDocumentOnStartup)
    autosaveDocument.state = getState(preferences.autosaveDocument)
    verticalSplitView.state = getState(preferences.verticalSplitView)
    modernTitlebar.state = getState(preferences.modernTitlebar)
    useSystemAppearance.state = getState(preferences.useSystemAppearance)
    showSidebar.state = getState(preferences.showSidebar)
    enableSpellcheck.state = getState(preferences.spellcheckEnabled)
    useThemeColorForSidebar.state = getState(preferences.useThemeColorForSidebar)
  }

  private func getState(_ state: Bool) -> NSControl.StateValue {
    return state ? .on : .off
  }

  @IBAction func syntaxChanged(_ sender: NSPopUpButton) {
    theme.setTheme(to: sender.title)
    postNotification()
  }

  @IBAction func showPreviewOnStartupChanged(_ sender: NSButton) {
    preferences.showPreviewOnStartup = sender.state.rawValue.bool
  }

  @IBAction func openNewDocumentOnStartupChanged(_ sender: NSButton) {
    preferences.openNewDocumentOnStartup = sender.state.rawValue.bool
  }

  @IBAction func autosaveDocumentChanged(_ sender: NSButton) {
    preferences.autosaveDocument = sender.state.rawValue.bool
  }

  @IBAction func verticalSplitViewChanged(_ sender: NSButton) {
    preferences.verticalSplitView = sender.state.rawValue.bool
    postNotification()
  }

  @IBAction func fontChanged(_ sender: NSButton) {
    let fontPanel = NSFontPanel.shared
    fontPanel.setPanelFont(preferences.font, isMultiple: false)
    fontPanel.makeKeyAndOrderFront(sender)
  }

  @IBAction func changeModernTitlebar(_ sender: NSButton) {
    preferences.modernTitlebar = sender.state.rawValue.bool
    postNotification()
  }

  @IBAction func changeUseSystemAppearance(_ sender: NSButton) {
    preferences.useSystemAppearance = sender.state.rawValue.bool
    postNotification()
  }

  @IBAction func showSidebarChanged(_ sender: NSButton) {
    preferences.showSidebar = sender.state.rawValue.bool
    postNotification()
  }

  @IBAction func enableSpellcheckChanged(_ sender: NSButton) {
    preferences.spellcheckEnabled = sender.state.rawValue.bool
    postNotification()
  }

  @IBAction func useThemeColorForSidebarChanged(_ sender: NSButton) {
    preferences.useThemeColorForSidebar = sender.state.rawValue.bool
    postNotification()
  }

  func changeFont(_ sender: NSFontManager?) {
    if let fontManager = sender {
      preferences.font = fontManager.convert(preferences.font)
      postNotification()
    }
  }

  @IBAction func revealThemes(_ sender: NSButton) {
    if let folder =  FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let styles = folder.appendingPathComponent("highlight-js/styles")
      NSWorkspace.shared.activateFileViewerSelecting([styles])
    }
  }

  private func postNotification() {
    NotificationCenter.send(.preferencesChanged)
  }

}
