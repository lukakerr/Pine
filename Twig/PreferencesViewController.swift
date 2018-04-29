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
  
  let wc = WindowController()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    syntaxDropdown.removeAllItems()
    
    for syntax in SYNTAX_THEMES {
      syntaxDropdown.addItem(withTitle: syntax)
    }
    
    syntaxDropdown.selectItem(withTitle: theme.syntax)
    
    showPreviewOnStartup.state = getState(preferences.showPreviewOnStartup)
    openNewDocumentOnStartup.state = getState(preferences.openNewDocumentOnStartup)
    autosaveDocument.state = getState(preferences.autosaveDocument)
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
  
  private func postNotification() {
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "changeThemeNotification"),
      object: nil
    )
  }
  
}
