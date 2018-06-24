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
  var items: [SidebarDocument] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  public func updateDocuments() {
    items = openDocuments.getDocuments()
    self.sidebar.reloadData()
  }

}
