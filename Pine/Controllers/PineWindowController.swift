//
//  PineWindowController.swift
//  Pine
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let AUTOSAVE_NAME = "PineWindow"

class PineWindowController: NSWindowController, NSWindowDelegate {

  private var toolbar: NSToolbar?
  private var toolbarData = ToolbarData()

  private var titlebarAccessoryController: NSTitlebarAccessoryViewController!

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

  /// The markdown view controller instance for this window
  private var markdownViewController: MarkdownViewController? {
    return editorSplitViewController?.splitViewItems.first?.viewController as? MarkdownViewController
  }

  /// The preview view controller instance for this window
  private var previewViewController: PreviewViewController? {
    return editorSplitViewController?.splitViewItems.last?.viewController as? PreviewViewController
  }

  override var acceptsFirstResponder: Bool {
    return true
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    // Setup notification observer for preferences change
    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(reloadUI))

    self.window?.setFrameAutosaveName(AUTOSAVE_NAME)

    // Set word count label in titlebar
    titlebarAccessoryController = storyboard?.instantiateController(
      withIdentifier: "titlebarViewController"
    ) as? NSTitlebarAccessoryViewController

    titlebarAccessoryController.layoutAttribute = .right
    window?.addTitlebarAccessoryViewController(titlebarAccessoryController)

    reloadUI()
  }

  override func showWindow(_ sender: Any?) {
    super.showWindow(sender)

    // Sync window sidebar after window becomes visible
    self.syncWindowSidebars()
  }

  private func setupToolbar() {
    toolbar = NSToolbar(identifier: "PineToolbar")
    toolbar?.delegate = self
    toolbar?.isVisible = true
    toolbar?.displayMode = .iconOnly
    toolbar?.allowsUserCustomization = true
    toolbar?.autosavesConfiguration = true

    window?.toolbar = toolbar
  }

  @objc private func reloadUI() {
    if preferences[.showToolbar] {
      self.setupToolbar()
    } else {
      window?.toolbar = nil
    }
  }

  func windowWillClose(_ notification: Notification) {
    // When a window is closed, a document is removed from the sidebar
    if let url = (document as? Document)?.fileURL {
      openDocuments.remove(itemWithUrl: url)
      syncWindowSidebars()
    }
  }

  public func syncWindowSidebars() {
    // Hacky way to get all sidebars and syncronize the sidebar data
    // Map over all windows (tabs) and find the sidebar
    getVisibleWindows().forEach {
      ($0.windowController as? PineWindowController)?.sidebarViewController?.sync()
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
    (DocumentController.shared as? DocumentController)?.replaceCurrentDocument(with: file)
  }

  // MARK: - First responder methods called by NSMenuItems applicable to the current window

  @IBAction func togglePreview(sender: NSMenuItem) {
    guard let preview = editorSplitViewController?.splitViewItems.last else { return }

    preview.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    preview.animator().isCollapsed = !preview.isCollapsed

    // If the preview is open after toggling, send a notification to re-generate the preview
    if !preview.isCollapsed {
      NotificationCenter.send(.markdownContentChanged)
    }

    if let svc = sidebarViewController {
      svc.setSidebarVisibility(hidden: svc.sidebarIsHidden)
    }
  }

  @IBAction func toggleEditor(sender: NSMenuItem) {
    guard let editor = editorSplitViewController?.splitViewItems.first else { return }

    editor.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
    editor.animator().isCollapsed = !editor.isCollapsed
  }

  // MARK: - Public static helper methods

  /// Returns the current window's document path
  public static func getCurrentDocument() -> String? {
    guard
      let window = NSApp.keyWindow?.windowController as? PineWindowController,
      let doc = window.document as? Document
    else { return nil }

    return doc.fileURL?.relativePath
  }

  // MARK: - Private helper functions

  private func getVisibleWindows() -> [NSWindow] {
    return NSApplication.shared.windows.filter { $0.isVisible }
  }

}

extension PineWindowController: NSToolbarDelegate {

  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    guard
      let toolbarItemInfo = toolbarData.toolbarItems.filter({ $0.identifier == itemIdentifier }).first
    else { return nil }

    var toolbarItem: NSToolbarItem

    if toolbarItemInfo.isSegmented, let children = toolbarItemInfo.children, let title = toolbarItemInfo.title {
      let segmented = ToolbarSegmentedControl(segments: children)

      let items: [NSToolbarItem] = children.enumerated().map { (index, child) in
        if let icon = child.icon, let image = NSImage(named: icon) {
          segmented.setImage(image, forSegment: index)
          segmented.setWidth(40, forSegment: index)
        } else if let iconTitle = child.iconTitle {
          segmented.setLabel(iconTitle, forSegment: index)
        }

        return makeToolbarItem(using: child)
      }

      let group = NSToolbarItemGroup(itemIdentifier: itemIdentifier)
      group.paletteLabel = title
      group.subitems = items
      group.view = segmented

      toolbarItem = group
    } else {
      toolbarItem = makeToolbarItem(using: toolbarItemInfo)
    }

    return toolbarItem
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return toolbarData.uniqueToolbarIdentifiers
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return toolbarData.toolbarIdentifiers
  }

  private func makeToolbarItem(using item: ToolbarItemInfo) -> NSToolbarItem {
    let toolbarItem = NSToolbarItem(itemIdentifier: item.identifier)

    if let title = item.title {
      toolbarItem.label = title
    }

    let button = NSButton()
    button.bezelStyle = .texturedRounded
    button.action = item.action

    if let icon = item.icon {
      let image = NSImage(named: icon)
      button.image = image
    } else if let iconTitle = item.iconTitle {
      button.title = iconTitle
    }

    toolbarItem.view = button

    return toolbarItem
  }

}

extension PineWindowController {

  // MARK: - First responder methods for exporting

  @IBAction func exportPDF(sender: NSMenuItem) {
    PDFExporter.export(from: markdownViewController)
  }

  @IBAction func exportHTML(sender: NSMenuItem) {
    HTMLExporter.export(from: previewViewController?.webPreview)
  }

  @IBAction func exportLatex(sender: NSMenuItem) {
    LatexExporter.export(from: markdownViewController?.markdownTextView)
  }

  @IBAction func exportXML(sender: NSMenuItem) {
    XMLExporter.export(from: markdownViewController?.markdownTextView)
  }

  @IBAction func exportTXT(sender: NSMenuItem) {
    TXTExporter.export(from: markdownViewController?.markdownTextView)
  }

}
