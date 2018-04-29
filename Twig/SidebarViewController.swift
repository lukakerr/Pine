//
//  SidebarViewController.swift
//  Twig
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

var files: [String] = []
var selectedIndex = -1

class SidebarViewController: NSViewController {
  
  @IBOutlet weak var sidebar: NSOutlineView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.filesChanged),
      name: NSNotification.Name(rawValue: "filesDidChange"),
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.selectedIndexChanged),
      name: NSNotification.Name(rawValue: "selectedIndexDidChange"),
      object: nil
    )
    
    // Setup notifications for window losing and gaining focus
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowLostFocus),
      name: NSApplication.willResignActiveNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowGainedFocus),
      name: NSApplication.willBecomeActiveNotification,
      object: nil
    )
  }
  
  @objc func filesChanged(notification: Notification?) {
    files = []
    for document in NSDocumentController.shared.documents {
      if let file = document.fileURL {
        files.append(String(describing: file.lastPathComponent))
      }
    }
    self.sidebar.reloadData()
  }
  
  @objc func selectedIndexChanged(_ notification: Notification?) {
    let windows = NSApplication.shared.windows.filter { $0.isVisible }
    let rows = IndexSet(integersIn: selectedIndex..<selectedIndex+1)
    
    // Hackish way to get all sidebars and syncronize the selected item
    // Iterate over all windows (tabs) and find the sidebar
    // If the window has the same index as the selected window, make it key
    for (index, window) in windows.enumerated() {
      if (index == selectedIndex) {
        window.makeKeyAndOrderFront(nil)
      }
      
      if let splitVC = window.contentViewController as? NSSplitViewController {
        if let sidebarVC = splitVC.childViewControllers[0] as? SidebarViewController {
          if selectedIndex != -1 {
            sidebarVC.sidebar.selectRowIndexes(rows, byExtendingSelection: false)
          }
        }
      }
    }
  }
  
}
