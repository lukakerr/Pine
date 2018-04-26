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
  
  let wc = WindowController()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    syntaxDropdown.removeAllItems()
    
    for syntax in SYNTAX_THEMES {
      syntaxDropdown.addItem(withTitle: syntax)
    }
    
    syntaxDropdown.selectItem(withTitle: theme.syntax)
  }
  
  @IBAction func syntaxChanged(_ sender: NSPopUpButton) {
    theme.syntax = sender.title
    postNotification()
  }
  
  private func postNotification() {
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "changeThemeNotification"),
      object: nil
    )
  }
  
}
