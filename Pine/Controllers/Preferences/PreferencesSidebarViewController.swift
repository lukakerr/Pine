//
//  PreferencesSidebarViewController.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesSidebarViewController: NSViewController {

  private var splitViewController: PreferencesSplitViewController? {
    return parent as? PreferencesSplitViewController
  }

  @IBOutlet weak private var sidebar: NSOutlineView!

  override func viewDidLoad() {
    super.viewDidLoad()

    sidebar.delegate = self
    sidebar.dataSource = self

    let selectedIndex = IndexSet(integer: 0)
    sidebar.selectRowIndexes(selectedIndex, byExtendingSelection: false)
  }

}

extension PreferencesSidebarViewController: NSOutlineViewDataSource {

  // Number of items in the sidebar
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    return PreferenceCategory.allCases.count
  }

  // Items to be added to sidebar
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    return PreferenceCategory.categories[index]
  }

  // Whether rows are expandable by an arrow
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return false
  }

  // Height of each row
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    return 35.0
  }

  // When a row is clicked on should it be selected
  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return true
  }

  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard
      let category = sidebar.item(atRow: sidebar.selectedRow) as? PreferenceCategory,
      let pvc = splitViewController?.splitViewItems.last?.viewController as? PreferencesViewController
    else { return }

    pvc.setCategory(category: category)
  }

}

extension PreferencesSidebarViewController: NSOutlineViewDelegate {

  // Create a cell given an item and set its properties
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let category = item as? PreferenceCategory else { return nil }

    let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"),
      owner: self
    ) as? NSTableCellView

    view?.textField?.font = NSFont.systemFont(ofSize: 14, weight: .bold)
    view?.textField?.stringValue = category.rawValue

    view?.imageView?.image = NSImage(named: category.rawValue)

    return view
  }

}
