//
//  SidebarViewController+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension SidebarViewController: NSOutlineViewDataSource {
  
  // Number of items in the sidebar
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    return files.count
  }
  
  // Items to be added to sidebar
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    return files[index]
  }
  
  // Whether rows are expandable by an arrow
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return false
  }
  
  // Height of each row
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    return 40.0
  }
  
  @objc func windowLostFocus(_ notification: Notification) {
    setRowColour(sidebar, false)
  }
  
  @objc func windowGainedFocus(_ notification: Notification) {
    setRowColour(sidebar, true)
  }
  
  // When a row is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    if let outlineView = notification.object as? NSOutlineView {
      setRowColour(outlineView, true)
      selectedIndex = outlineView.selectedRow
      selectedIndexChanged(nil)
    }
  }
  
  func setRowColour(_ outlineView: NSOutlineView, _ windowFocused: Bool) {
    let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)
    let rowViews = rows.compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }
    
    // Iterate over each row in the outlineView
    for rowView in rowViews {
      if windowFocused && rowView.isSelected {
        rowView.backgroundColor = NSColor(red: 0.69, green: 0.76, blue: 0.90, alpha: 0.5)
      } else if rowView.isSelected {
        rowView.backgroundColor = NSColor(red: 0.89, green: 0.89, blue: 0.88, alpha: 0.5)
      } else {
        rowView.backgroundColor = .clear
      }
    }
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
      view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"), owner: self) as? NSTableCellView
      if let textField = view?.textField {
        textField.stringValue = title
        textField.sizeToFit()
      }
    }
    
    return view
  }
  
}
