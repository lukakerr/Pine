//
//  PreferencesViewController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

  @IBOutlet weak var syntaxDropdown: NSPopUpButton!
  @IBOutlet weak var showPreviewOnStartup: NSButton!
  @IBOutlet weak var openNewDocumentOnStartup: NSButton!
  @IBOutlet weak var autosaveDocument: NSButton!
  @IBOutlet weak var verticalSplitView: NSButton!
  @IBOutlet weak var modernTitlebar: NSButton!
  @IBOutlet weak var useSystemAppearance: NSButton!
  @IBOutlet weak var showSidebar: NSButton!

  let wc = WindowController()

  override func viewDidLoad() {
    super.viewDidLoad()

    syntaxDropdown.removeAllItems()

    for syntax in SyntaxThemes.ThemeList {
      syntaxDropdown.addItem(withTitle: syntax)
    }

    syntaxDropdown.selectItem(withTitle: theme.syntax)

    showPreviewOnStartup.state = getState(preferences.showPreviewOnStartup)
    openNewDocumentOnStartup.state = getState(preferences.openNewDocumentOnStartup)
    autosaveDocument.state = getState(preferences.autosaveDocument)
    verticalSplitView.state = getState(preferences.verticalSplitView)
    modernTitlebar.state = getState(preferences.modernTitlebar)
    useSystemAppearance.state = getState(preferences.useSystemAppearance)
    showSidebar.state = getState(preferences.showSidebar)
  }

  private func getState(_ state: Bool) -> NSControl.StateValue {
    return state ? .on : .off
  }

  @IBAction func syntaxChanged(_ sender: NSPopUpButton) {
    theme.syntax = sender.title
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

  override func changeFont(_ sender: Any?) {
    if let fontManager = sender as? NSFontManager {
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
    NotificationCenter.send("preferencesChanged")
  }

}
