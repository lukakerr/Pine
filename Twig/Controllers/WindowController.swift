//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    // set word count label in titlebar
    if let titlebarController = self.storyboard?.instantiateController(withIdentifier: "titlebarViewController") as? NSTitlebarAccessoryViewController {
      titlebarController.layoutAttribute = .right
      self.window?.addTitlebarAccessoryViewController(titlebarController)
      self.showWindow(self.window)
    }
  }

}
