//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let AUTOSAVE_NAME = "TwigWindow"

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

    self.window?.setFrameAutosaveName(AUTOSAVE_NAME)

    // Set word count label in titlebar
    guard let titlebarController = storyboard?.instantiateController(
      withIdentifier: "titlebarViewController"
    ) as? NSTitlebarAccessoryViewController else { return }

    titlebarController.layoutAttribute = .right
    window?.addTitlebarAccessoryViewController(titlebarController)
  }

  public func syncWindowSidebars() {
    // Hacky way to get all sidebars and syncronize the sidebar data
    // Map over all windows (tabs) and find the sidebar
    getVisibleWindows().forEach {
      ($0.windowController as? WindowController)?.sidebarViewController?.updateDocuments()
    }
  }

  func windowWillClose(_ notification: Notification) {
    // When a window is closed, a document is removed from the sidebar
    if let url = (document as? Document)?.fileURL {
      openDocuments.remove(itemWithUrl: url)
      syncWindowSidebars()
    }
  }

  public func changeDocument(file: URL) {
    // Check if document is already open in a tab first
    for window in getVisibleWindows() {
      guard let doc = window.windowController?.document as? Document else { continue }

      if doc.fileURL == file {
        window.makeKeyAndOrderFront(nil)
        syncWindowSidebars()
        return
      }
    }

    // Otherwise open document in current tab
    DocumentController.replaceCurrentDocument(with: file)
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

  @IBAction func toggleEditor(sender: NSMenuItem) {
    guard let editor = editorSplitViewController?.splitViewItems.first else { return }

    editor.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    editor.animator().isCollapsed = !editor.isCollapsed

    // If the editor is open after toggling, send a notification to re-generate the preview
    if !editor.isCollapsed {
      NotificationCenter.send(.appearanceChanged)
    }
  }

  // MARK: - Public static helper methods

  /// Returns the current window's document path
  public static func getCurrentDocument() -> String? {
    guard
      let window = NSApp.keyWindow?.windowController as? WindowController,
      let doc = window.document as? Document
    else { return nil }

    return doc.fileURL?.relativePath
  }

  // MARK: - Private helper functions

  private func getVisibleWindows() -> [NSWindow] {
    return NSApplication.shared.windows.filter { $0.isVisible }
  }

}
