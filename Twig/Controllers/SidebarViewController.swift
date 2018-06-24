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
  var items: [String] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  public func updateDocuments() {
    items = openDocuments.getDocuments()
    self.sidebar.reloadData()
  }

}

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
    return 30.0
  }

  // When a row is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    if let outlineView = notification.object as? NSOutlineView {
      setRowColour(outlineView)
    }
  }

  func setRowColour(_ outlineView: NSOutlineView) {
    let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)
    let rowViews = rows.compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }
    var initialLoad = true

    // Iterate over each row in the outlineView
    for rowView in rowViews {
      if rowView.isSelected {
        initialLoad = false
      }

      if rowView.isSelected {
        rowView.backgroundColor = .selectedControlColor
      } else {
        rowView.backgroundColor = .clear
      }
    }

    if initialLoad {
      self.setInitialRowColour()
    }
  }

  func setInitialRowColour() {
    sidebar.rowView(
      atRow: 0,
      makeIfNecessary: true
    )?.backgroundColor = .selectedControlColor
  }

  // Remove default selection colour
  func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
    rowView.selectionHighlightStyle = .none
  }

}

extension SidebarViewController: NSOutlineViewDelegate {

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    var view: NSTableCellView?

    if let title = item as? String {
      view = outlineView.makeView(
        withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"),
        owner: self
      ) as? NSTableCellView
      if let textField = view?.textField {
        textField.stringValue = title
        textField.sizeToFit()
      }
    }

    return view
  }

}
