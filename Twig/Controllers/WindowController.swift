//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

  /// The split view controller containing the SidebarViewController and editor split view controller
  private var mainSplitViewController: NSSplitViewController? {
    return contentViewController as? NSSplitViewController
  }

  /// The split view controller containing the MarkdownViewController and PreviewViewController
  private var editorSplitViewController: NSSplitViewController? {
    return mainSplitViewController?.splitViewItems.last?.viewController as? NSSplitViewController
  }

  /// The sidebar view controller
  private var sidebarViewController: SidebarViewController? {
    return mainSplitViewController?.splitViewItems.first?.viewController as? SidebarViewController
  }

  override var acceptsFirstResponder: Bool {
    return true
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    // set word count label in titlebar
    guard let titlebarController = storyboard?.instantiateController(
      withIdentifier: "titlebarViewController"
    ) as? NSTitlebarAccessoryViewController else { return }

    titlebarController.layoutAttribute = .right
    window?.addTitlebarAccessoryViewController(titlebarController)
    showWindow(window)
  }

  public func syncWindowSidebars() {
    let windows = NSApplication.shared.windows.filter { $0.isVisible }

    // Hackish way to get all sidebars and syncronize the sidebar data
    // Map over all windows (tabs) and find the sidebar
    windows.forEach { _ in sidebarViewController?.updateDocuments() }
  }

  func windowWillClose(_ notification: Notification) {
    // When a window is closed, a document is removed from the sidebar
    if let url = (document as? Document)?.fileURL {
      openDocuments.removeDocument(with: url)
      syncWindowSidebars()
    }
  }

  public func changeDocument(file: URL) {
    // Check if document is already open in a tab first
    let windows = NSApplication.shared.windows.filter { $0.isVisible }

    for window in windows {
      guard let doc = window.windowController?.document as? Document else { continue }

      if doc.fileURL == file {
        window.makeKeyAndOrderFront(nil)
        syncWindowSidebars()
        return
      }
    }

    // Otherwise open document in current tab
    if let doc = document as? Document {
      try? doc.read(from: file, ofType: file.pathExtension)
    }
  }

  // MARK: - First responder methods called by NSMenuItems applicable to the current window

  @IBAction func togglePreview(sender: NSMenuItem) {
    guard let preview = editorSplitViewController?.splitViewItems.last else { return }

    preview.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    preview.animator().isCollapsed = !preview.isCollapsed

    // If the preview is open after toggling, send a notification to re-generate the preview
    if !preview.isCollapsed {
      NotificationCenter.send(.appearanceChanged)
    }
  }

  @IBAction func toggleSidebar(sender: NSMenuItem) {
    guard let sidebar = mainSplitViewController?.splitViewItems.first else { return }

    sidebar.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    sidebar.animator().isCollapsed = !sidebar.isCollapsed
  }

}
