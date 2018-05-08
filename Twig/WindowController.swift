//
//  WindowController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    self.handleTransparentView()
    
    // Setup notification observer for preferences change
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleTransparentView),
      name: NSNotification.Name(rawValue: "preferencesChanged"),
      object: nil
    )
  }
  
  // When preferences.transparentEditingView is changed this gets called
  // It sets the properties for the NSVisualEffectView based on the users preferences
  @objc private func handleTransparentView() {
    if let window = self.window {
      if preferences.transparentEditingView {
        window.styleMask.insert(.fullSizeContentView)
        window.isMovable = true
      } else {
        window.styleMask.remove(.fullSizeContentView)
      }
      if let splitViewController = window.contentViewController as? NSSplitViewController {
        if let markdownViewItem = splitViewController.splitViewItems.first {
          if let markdownViewController = markdownViewItem.viewController as? MarkdownViewController {
            markdownViewController.markdownTextView.textContainerInset.height = preferences.transparentEditingView ? 30.0 : 10.0
            markdownViewController.transparentView.isHidden = !preferences.transparentEditingView
          }
          
          if let previewViewController = splitViewController.splitViewItems.last {
            previewViewController.isCollapsed = !preferences.showPreviewOnStartup
          }
        }
      }
    }
  }

}
