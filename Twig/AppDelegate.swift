//
//  AppDelegate.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }

  func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
    return preferences.openNewDocumentOnStartup
  }

  // MARK: - First responder methods that can be called anywhere in the application

  @IBAction func openFolder(sender: NSMenuItem) {
    let dialog = NSOpenPanel()

    dialog.title = "Open a folder"
    dialog.allowsMultipleSelection = false
    dialog.canChooseFiles = false
    dialog.canCreateDirectories = true
    dialog.canChooseDirectories = true

    if dialog.runModal() == .OK {
      if let result = dialog.url {
        let parent = FileSystemItem.createParents(url: result)
        let newItem = FileSystemItem(path: result.absoluteString, parent: parent)

        openDocuments.addDocument(newItem)
        (NSApplication.shared.keyWindow?.windowController as? WindowController)?.syncWindowSidebars()
      }
    }
  }

}
