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
    guard let titlebarController = self.storyboard?.instantiateController(
      withIdentifier: "titlebarViewController"
    ) as? NSTitlebarAccessoryViewController else { return }

    titlebarController.layoutAttribute = .right
    self.window?.addTitlebarAccessoryViewController(titlebarController)
    self.showWindow(self.window)
  }

  public func syncWindowSidebars() {
    let windows = NSApplication.shared.windows.filter { $0.isVisible }

    // Hackish way to get all sidebars and syncronize the sidebar data
    // Iterate over all windows (tabs) and find the sidebar
    for window in windows {
      if let splitVC = window.contentViewController as? NSSplitViewController {
        if let sidebarVC = splitVC.children.first as? SidebarViewController {
          sidebarVC.updateDocuments()
        }
      }
    }
  }

}
