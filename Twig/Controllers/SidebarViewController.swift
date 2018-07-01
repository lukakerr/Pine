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
    updateSidebarVisibility()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup notification observer for preferences change
    NotificationCenter.receive(
      .preferencesChanged,
      instance: self,
      selector: #selector(self.updateSidebarVisibility)
    )
  }

  public func updateDocuments() {
    items = openDocuments.getDocuments()
    self.sidebar.reloadData()
  }

  @objc private func updateSidebarVisibility() {
    if let svc = self.parent as? NSSplitViewController {
      svc.splitViewItems.first?.isCollapsed = !preferences.showSidebar
    }
  }

}
