//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

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

  func windowWillClose(_ notification: Notification) {
    // When a window is closed, a document is removed from the sidebar

    if let url = (self.document as? Document)?.fileURL {
      openDocuments.removeDocument(with: url)
      self.syncWindowSidebars()
    }
  }

  public func changeDocument(file: URL) {
    // Check if document is already open in a tab first
    let windows = NSApplication.shared.windows.filter { $0.isVisible }
    for window in windows where window.windowController?.document?.fileURL == file {
      window.makeKeyAndOrderFront(nil)
      self.syncWindowSidebars()
      return
    }

    // Otherwise open document in current tab
    if let doc = self.document as? Document {
      try? doc.read(from: file, ofType: file.pathExtension)
    }
  }

}
