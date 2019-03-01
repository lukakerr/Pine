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
  @IBOutlet weak var sidebarActionsView: NSView!

  // Data used for sidebar rows
  var items: [FileSystemItem] = []

  // Whether the sidebar's structure has been synced yet
  // The structure is only set once on first load
  var structureHasSynced: Bool = false

  /// The split view item holding this sidebar view controller
  private var sidebarSplitViewItem: NSSplitViewItem? {
    return (parent as? NSSplitViewController)?.splitViewItems.first
  }

  /// The sidebar view's window controller
  private var windowController: TwigWindowController? {
    return view.window?.windowController as? TwigWindowController
  }

  override func viewWillAppear() {
    updateSidebarAppearance()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup notification observer for preferences change
    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(updateSidebarAppearance))

    // Setup selector for when row in sidebar is double clicked
    sidebar.doubleAction = #selector(doubleClicked)

    // Setup the contextual menus for sidebar items
    setContextualMenu()
  }

  public func updateDocuments() {
    items = openDocuments.getDocuments()
    sidebar.reloadData()

    if !structureHasSynced {
      syncSidebarStructure()
      structureHasSynced = true
    }

    syncSelectedRows()
  }

  @IBAction func toggleSidebar(_ sender: NSButton) {
    sidebarSplitViewItem?.isCollapsed.toggle()
  }

  // MARK: - Private functions for controlling the sidebar view UI

  /// Sync the expanded/collapsed structure of the sidebar
  private func syncSidebarStructure() {
    var row = 0

    // A while loop is used since when an item is expanded,
    // the numberOfRows increases and must be recalculated
    while row < sidebar.numberOfRows {
      guard
        let rowItem = sidebar.item(atRow: row) as? FileSystemItem
      else { continue }

      syncItemStructure(rowItem)

      row += 1
    }
  }

  /// Recursive function that when given an item, expands it
  /// and all of its nested children, if necessary
  private func syncItemStructure(_ item: FileSystemItem) {
    if item.isExpanded {
      sidebar.expandItem(item)
    } else {
      return
    }

    let childIndexes = item.getNumberOfChildren() - 1

    guard childIndexes >= 0 else { return }

    for index in 0...childIndexes {
      let child = item.getChild(at: index)

      if child.isExpanded {
        sidebar.expandItem(child)
        syncItemStructure(child)
      }
    }
  }

  /// Set a contextual menu (called on right click) for the sidebar
  private func setContextualMenu() {
    let menu = NSMenu()
    menu.delegate = self

    let removeItem = NSMenuItem()
    removeItem.title = "Remove from sidebar"
    removeItem.action = #selector(removeItemFromSidebar)

    menu.addItem(removeItem)
    sidebar.menu = menu
  }

  // MARK: - Private functions for updating the sidebar and its rows

  /// Called when the 'remove from sidebar' NSMenuItem is clicked
  @objc private func removeItemFromSidebar(_ sender: NSMenuItem) {
    guard
      let itemToRemove = sidebar.item(atRow: sidebar.clickedRow) as? FileSystemItem
    else { return }

    openDocuments.remove(item: itemToRemove)
    windowController?.syncWindowSidebars()
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

  /// Update the sidebar appearance based on any preferences and the theme
  @objc private func updateSidebarAppearance() {
    sidebarSplitViewItem?.isCollapsed = !preferences.showSidebar

    let backgroundColor = preferences.useThemeColorForSidebar ? theme.background : .clear

    sidebar.backgroundColor = backgroundColor
    sidebarActionsView.setBackgroundColor(backgroundColor)
    setRowColour(sidebar)
    sidebar.reloadData()
  }

  /// Set each row's `isSelected` property based on if it is the current open document
  private func syncSelectedRows() {
    guard let docPath = TwigWindowController.getCurrentDocument() else { return }

    for row in getRows() {
      guard
        let rowItem = sidebar.item(atRow: row) as? FileSystemItem,
        let rowView = sidebar.rowView(atRow: row, makeIfNecessary: true)
      else { continue }

      rowView.isSelected = rowItem.fullPath == docPath
    }

    setRowColour(sidebar)
  }

  // MARK: - Private helper functions

  /// Get an `IndexSet` containing each row's index
  private func getRows() -> IndexSet {
    return IndexSet(integersIn: 0..<sidebar.numberOfRows)
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

  // Whether the row should be expanded
  func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
    guard let item = item as? FileSystemItem else { return false }

    item.isExpanded = true

    return true
  }

  // Whether a row should be collapsed
  func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
    guard let item = item as? FileSystemItem else { return false }

    item.isExpanded = false

    return true
  }

  // When a row is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard
      let doc = sidebar.item(atRow: sidebar.selectedRow) as? FileSystemItem,
      let window = view.window?.windowController as? TwigWindowController
    else { return }

    setRowColour(sidebar)

    if doc.isDirectory { return }

    window.changeDocument(file: doc.fileURL)
  }

  /// Given an `NSOutlineView` instance, set any selected rows to have a
  /// background color and any non-selected rows to have a clear background color
  func setRowColour(_ outlineView: NSOutlineView) {
    getRows()
      .compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }
      .forEach {
        $0.backgroundColor = $0.isSelected ? .selectedControlColor : .clear
        setRowTextColor(forRow: $0)
      }
  }

  private func setRowTextColor(forRow row: NSTableRowView) {
    if let cell = row.view(atColumn: 0) as? NSTableCellView {
      let isDark = sidebar.backgroundColor.isDark
      let selectedAndDark = row.isSelected && isDark

      let textColor: NSColor = isDark || selectedAndDark ? .white : .black

      cell.textField?.textColor = textColor
    }
  }

  // Remove default selection colour
  func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
    rowView.selectionHighlightStyle = .none

    guard let docPath = TwigWindowController.getCurrentDocument() else { return }

    for (index, item) in items.enumerated() where index == row && item.fullPath == docPath {
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
      view?.imageView?.image = NSImage(named: "Folder")
    } else {
      view?.imageView?.image = NSImage(named: "Markdown")
    }

    view?.imageView?.image?.isTemplate = true

    return view
  }

}

extension SidebarViewController: NSMenuDelegate {

  /// Called when the menu is about to open.
  /// If the clicked item is not a top level item, we cancel the menu
  func menuWillOpen(_ menu: NSMenu) {
    guard
      let itemToRemove = sidebar.item(atRow: sidebar.clickedRow) as? FileSystemItem
    else { return }

    if !openDocuments.contains(itemToRemove) {
      menu.cancelTracking()
    }
  }

}

