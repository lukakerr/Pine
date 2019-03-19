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

  private lazy var toolbarItems: [ToolbarItemInfo] = [
    ToolbarItemInfo(identifier: .toggleSidebar),
    ToolbarItemInfo(identifier: .space),
    ToolbarItemInfo(
      title: "Heading 1",
      iconTitle: "H1",
      action: #selector(MarkdownViewController.h1),
      identifier: .h1
    ),
    ToolbarItemInfo(
      title: "Heading 2",
      iconTitle: "H2",
      action: #selector(MarkdownViewController.h2),
      identifier: .h2
    ),
    ToolbarItemInfo(
      title: "Heading 3",
      iconTitle: "H3",
      action: #selector(MarkdownViewController.h3),
      identifier: .h3
    ),
    ToolbarItemInfo(identifier: .space),
    ToolbarItemInfo(
      title: "Bold",
      icon: NSImage.Name(stringLiteral: "Bold"),
      action: #selector(MarkdownViewController.bold),
      identifier: .bold
    ),
    ToolbarItemInfo(
      title: "Italic",
      icon: NSImage.Name(stringLiteral: "Italic"),
      action: #selector(MarkdownViewController.italic),
      identifier: .italic
    ),
    ToolbarItemInfo(identifier: .space),
    ToolbarItemInfo(
      title: "Code",
      iconTitle: "<>",
      action: #selector(MarkdownViewController.code),
      identifier: .code
    ),
    ToolbarItemInfo(
      title: "Math",
      iconTitle: "$$",
      action: #selector(MarkdownViewController.math),
      identifier: .math
    ),
    ToolbarItemInfo(
      title: "Image",
      iconTitle: "<img>",
      action: #selector(MarkdownViewController.image),
      identifier: .image
    ),
  ]

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

    reloadUI()

    // Set word count label in titlebar
    guard let titlebarController = storyboard?.instantiateController(
      withIdentifier: "titlebarViewController"
    ) as? NSTitlebarAccessoryViewController else { return }

    titlebarController.layoutAttribute = .right
    window?.addTitlebarAccessoryViewController(titlebarController)
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
    if preferences[Preference.showToolbar] {
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

  var toolbarIdentifiers: [NSToolbarItem.Identifier] {
    return toolbarItems.compactMap { $0.identifier }
  }

  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    guard
      let toolbarItemInfo = toolbarItems.filter({ $0.identifier == itemIdentifier }).first
    else { return nil }

    let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

    if let title = toolbarItemInfo.title {
      toolbarItem.label = title
    }

    let button = NSButton()
    button.bezelStyle = .texturedRounded
    button.action = toolbarItemInfo.action

    if let icon = toolbarItemInfo.icon {
      let image = NSImage(named: icon)
      button.image = image
    } else if let iconTitle = toolbarItemInfo.iconTitle {
      button.title = iconTitle
    }

    toolbarItem.view = button

    return toolbarItem
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    // Only want unique identifiers
    return Array(Set(toolbarIdentifiers))
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return toolbarIdentifiers
  }
}

extension PineWindowController {

  // MARK: - First responder methods for exporting

  @IBAction func exportPDF(sender: NSMenuItem) {
    PDFExporter.export(from: previewViewController?.webPreview)
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
