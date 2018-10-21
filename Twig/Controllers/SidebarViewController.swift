//
//  SidebarViewController.swift
//  Twig
//
//  Created by Luka Kerr on 24/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {

  @IBOutlet weak var sidebar: NSOutlineView!

  // Data used for sidebar rows
  var items: [FileSystemItem] = []

  override func viewWillAppear() {
    updateSidebarAppearance()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup notification observer for preferences change
    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(updateSidebarAppearance))

    // Setup selector for when row in sidebar is double clicked
    sidebar.doubleAction = #selector(doubleClicked)
  }

  public func updateDocuments() {
    items = openDocuments.getDocuments()
    sidebar.reloadData()
  }

  /// Called when the a row in the sidebar is double clicked
  @objc private func doubleClicked(_ sender: Any?) {
    let clickedRow = sidebar.item(atRow: sidebar.clickedRow)

    if sidebar.isItemExpanded(clickedRow) {
      sidebar.collapseItem(clickedRow)
    } else {
      sidebar.expandItem(clickedRow)
    }
  }

  @objc private func updateSidebarAppearance() {
    (parent as? NSSplitViewController)?.splitViewItems.first?.isCollapsed = !preferences.showSidebar
    sidebar.backgroundColor = preferences.useThemeColorForSidebar ? theme.background : .clear
  }

}

extension SidebarViewController: NSOutlineViewDataSource {

  // Number of items in the sidebar
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item as? FileSystemItem else { return items.count }
    return item.getNumberOfChildren()
  }

  // Items to be added to sidebar
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item as? FileSystemItem else { return items[index] }
    return item.getChild(at: index)
  }

  // Whether rows are expandable by an arrow
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    guard let item = item as? FileSystemItem else { return false }
    return item.getNumberOfChildren() != 0
  }

  // Height of each row
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    return 30.0
  }

  // When a row is clicked on should it be selected
  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return true
  }

  // When a row is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard
      let doc = sidebar.item(atRow: sidebar.selectedRow) as? FileSystemItem,
      let window = view.window?.windowController as? WindowController
    else { return }

    setRowColour(sidebar)

    if doc.isDirectory { return }

    window.changeDocument(file: doc.fileURL)
  }

  func setRowColour(_ outlineView: NSOutlineView) {
    let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)

    rows
      .compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }
      .forEach { $0.backgroundColor = $0.isSelected ? .selectedControlColor : .clear }
  }

  // Remove default selection colour
  func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
    rowView.selectionHighlightStyle = .none

    guard
      let window = view.window?.windowController as? WindowController,
      let doc = window.document as? Document
    else { return }

    for (index, item) in items.enumerated()
      where index == row && item.fullPath == doc.fileURL?.relativePath {
        rowView.isSelected = true
    }

    setRowColour(outlineView)
  }

}

extension SidebarViewController: NSOutlineViewDelegate {

  // Create a cell given an item and set its properties
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let item = item as? FileSystemItem else { return nil }

    let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"),
      owner: self
    ) as? NSTableCellView
    view?.textField?.stringValue = item.getName()

    if item.isDirectory {
      view?.imageView?.image = NSImage(named: NSImage.folderName)
    } else {
      view?.imageView?.image = NSWorkspace.shared.icon(forFileType: item.fileType)
    }

    return view
  }

}

