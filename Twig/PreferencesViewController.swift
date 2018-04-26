//
//  PreferencesViewController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  
  @IBOutlet weak var themeButton: NSSegmentedControl!
  @IBOutlet weak var syntaxDropdown: NSPopUpButton!
  
  let wc = WindowController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    themeButton.selectedSegment = theme.id
    syntaxDropdown.removeAllItems()
    
    for syntax in SYNTAX_THEMES {
      syntaxDropdown.addItem(withTitle: syntax)
    }
    
    syntaxDropdown.selectItem(withTitle: theme.syntax)
  }
  
  @IBAction func themeChanged(_ sender: NSSegmentedControl) {
    let chosenTheme = (sender.selectedSegment == 0) ? ThemeType.light : ThemeType.dark
    theme.setTheme(chosenTheme)
    self.view.window?.appearance = NSAppearance(named: theme.appearance)
    postNotification()
  }
  
  @IBAction func syntaxChanged(_ sender: NSPopUpButton) {
    theme.syntax = sender.title
//    theme.setSyntax(sender.title)
    postNotification()
  }
  
  private func postNotification() {
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "changeThemeNotification"),
      object: nil
    )
  }
  
}
