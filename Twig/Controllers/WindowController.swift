//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

  override var acceptsFirstResponder: Bool {
    return true
  }

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

    for window in windows {
      guard
        let doc = window.windowController?.document as? Document,
        let url = doc.fileURL
      else { continue }

      if url == file {
        window.makeKeyAndOrderFront(nil)
        self.syncWindowSidebars()
        return
      }
    }

    // Otherwise open document in current tab
    if let doc = self.document as? Document {
      try? doc.read(from: file, ofType: file.pathExtension)
    }
  }

  // MARK: - First responder methods called by NSMenuItems

  @IBAction func togglePreview(sender: NSMenuItem) {
    guard
      let svc = self.contentViewController as? NSSplitViewController,
      let evc = svc.splitViewItems.last?.viewController as? NSSplitViewController,
      let preview = evc.splitViewItems.last
    else { return }

    preview.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    preview.animator().isCollapsed = !preview.isCollapsed
  }

  @IBAction func toggleSidebar(sender: NSMenuItem) {
    guard
      let svc = self.contentViewController as? NSSplitViewController,
      let sidebar = svc.splitViewItems.first
    else { return }

    sidebar.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    sidebar.animator().isCollapsed = !sidebar.isCollapsed
  }

  @IBAction func openFolder(sender: NSMenuItem) {
    let dialog = NSOpenPanel()

    dialog.title = "Open a folder"
    dialog.allowsMultipleSelection = false
    dialog.canChooseFiles = false
    dialog.canCreateDirectories = true
    dialog.canChooseDirectories = true

    if dialog.runModal() == .OK {
      if let result = dialog.url {
        let parent = FileSystemItem.createParents(url: result)
        let newItem = FileSystemItem(path: result.absoluteString, parent: parent)

        openDocuments.addDocument(newItem)
        self.syncWindowSidebars()
      }
    }
  }

}
