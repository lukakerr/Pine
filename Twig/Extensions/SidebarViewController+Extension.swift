//
//  SidebarViewController+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 24/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension SidebarViewController: NSOutlineViewDataSource {

  // Number of items in the sidebar
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    return items.count
  }

  // Items to be added to sidebar
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    return items[index]
  }

  // Whether rows are expandable by an arrow
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return false
  }

  // Height of each row
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    if let item = item as? SidebarDocument {
      if item.type == .header {
        return 20.0
      }
    }
    return 30.0
  }

  // When a row is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    if let outlineView = notification.object as? NSOutlineView {
      if let doc = outlineView.item(atRow: outlineView.selectedRow) as? SidebarDocument {
        if doc.type == .header {
          return
        }
        setRowColour(outlineView)
        if let window = self.view.window?.windowController as? WindowController, let url = doc.url {
          window.changeDocument(file: url)
        }
      }
    }
  }

  func setRowColour(_ outlineView: NSOutlineView) {
    let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)
    let rowViews = rows.compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }

    // Iterate over each row in the outlineView
    for rowView in rowViews {
      rowView.backgroundColor = rowView.isSelected ? .selectedMenuItemColor : .clear
    }
  }

  // Remove default selection colour
  func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
    rowView.selectionHighlightStyle = .none

    guard
      let window = self.view.window?.windowController as? WindowController,
      let doc = window.document as? NSDocument
    else { return }

    for (index, item) in items.enumerated()
      where index == row && item.url == doc.fileURL && item.type != .header {
        rowView.isSelected = true
    }

    setRowColour(outlineView)
  }

}

extension SidebarViewController: NSOutlineViewDelegate {

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    var view: NSTableCellView?

    guard let item = item as? SidebarDocument else { return nil }

    switch item.type {
    case .header:
      view = outlineView.makeView(
        withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"),
        owner: self
        ) as? NSTableCellView
      view?.textField?.stringValue = item.name
    default:
      view = outlineView.makeView(
        withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"),
        owner: self
        ) as? NSTableCellView
      view?.textField?.stringValue = item.name
    }

    return view
  }

}
