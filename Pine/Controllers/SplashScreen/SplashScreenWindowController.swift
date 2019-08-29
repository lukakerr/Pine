//
//  SplashScreenWindowController.swift
//  Pine
//
//  Created by Luka Kerr on 28/8/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class SplashScreenWindowController: NSWindowController {

  @IBOutlet var recentDocumentsArrayController: NSArrayController!
  @IBOutlet weak var splashScreenImageView: NSImageView!
  @IBOutlet weak var applicationName: NSTextField!

  @objc dynamic var applicationVersion: String = ""
  @objc dynamic var recentDocumentViewControllers = [SplashScreenRecentDocumentViewController]()

  override var windowNibName: NSNib.Name? {
    return "SplashScreenWindowController"
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    window?.titleVisibility = .hidden
    window?.titlebarAppearsTransparent = true
    window?.isMovableByWindowBackground = true

    splashScreenImageView.image = NSApplication.shared.applicationIconImage

    let dictionary = Bundle.main.infoDictionary!
    let name = dictionary["CFBundleName"] as? String
    let version = dictionary["CFBundleShortVersionString"] as? String

    applicationName.stringValue = name ?? ""

    if let cfBundleVersion = version {
      applicationVersion = cfBundleVersion
    }

    recentDocumentViewControllers = getRecentDocumentViewControllers()
  }

  // MARK: - IBActions

  @IBAction func createNewDocument(_ sender: NSButton) {
    let documentController = NSDocumentController.shared

    do {
      try documentController.openUntitledDocumentAndDisplay(true)
      self.close()
    } catch let e as NSError {
      let alert = NSAlert()
      alert.messageText = e.localizedFailureReason ?? e.localizedDescription
      alert.informativeText = e.localizedRecoverySuggestion ?? ""
      alert.runModal()
    }
  }

  @IBAction func openSampleProject(_ sender: Any) {
    preloadDBData()
  }

  @IBAction func didDoubleClickRecentDocument(_ sender: NSTableView) {
    let clickedRow = sender.clickedRow
    guard clickedRow >= 0 else { return }
    let documentController = NSDocumentController.shared
    let viewController = recentDocumentViewControllers[clickedRow]

    guard let url = viewController.url  else { return }

    let parent = FileSystemItem.createParents(url: url)
    let newItem = FileSystemItem(path: url.absoluteString, parent: parent)
    openDocuments.addDocument(newItem)

    documentController.openDocument(withContentsOf: url, display: true) {
      (_: NSDocument?, _: Bool, _: Error?) in
      self.close()
    }
  }

  func preloadDBData() {
    let pathMD = Bundle.main.path(forResource: "MARKDOWN_REFERENCE", ofType: "md")

    let urlFrom = URL(fileURLWithPath: pathMD!)
    let urlTo = URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/MARKDOWN_REFERENCE.md")

    if FileManager.default.fileExists(atPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/MARKDOWN_REFERENCE.md") {
      do {
        try FileManager.default.removeItem(at: urlTo)
      } catch {}
    }

    do {
      try FileManager.default.copyItem(at: urlFrom, to: urlTo)
    } catch {}

    let parent = FileSystemItem.createParents(url: urlTo)
    let newItem = FileSystemItem(path: urlTo.absoluteString, parent: parent)
    openDocuments.addDocument(newItem)

    let documentController = NSDocumentController.shared
    documentController.openDocument(withContentsOf: urlTo, display: true) {
      (_: NSDocument?, _: Bool, _: Error?) in
      self.close()
    }
  }

  func getBundleExtension() -> String {
    let documentTypes = Bundle.main.infoDictionary!["CFBundleDocumentTypes"] as! [[String: AnyObject]]
    let extensions = documentTypes.first!["CFBundleTypeExtensions"] as! [String]
    return extensions.first!
  }

  // MARK: - Private methods

  private func getRecentDocumentViewControllers() -> [SplashScreenRecentDocumentViewController] {
    let projectExtension = getBundleExtension()
    let documentController = NSDocumentController.shared

    var recentDocumentViewControllers = [SplashScreenRecentDocumentViewController]()
    var recentDocumentURLs = Set<URL>()
    let fileManager = FileManager.default

    for url in documentController.recentDocumentURLs {
      let path = url.path
      guard path.contains(projectExtension) else { continue }
      if !fileManager.isReadableFile(atPath: path) {
        continue
      }

      let components: [String] = url.pathComponents
      var i = components.count - 1
      repeat {
        if (components[i] as NSString).pathExtension == projectExtension {
          break
        }

        i -= 1
      } while i > 0

      let projectURL: URL

      if i == components.count - 1 {
        projectURL = url
      } else {
        let projectComponents = [String](components.prefix(i + 1))
        projectURL = NSURL.fileURL(withPathComponents: projectComponents)! as URL
      }

      if recentDocumentURLs.contains(projectURL) {
        continue
      }

      recentDocumentURLs.insert(projectURL)

      let viewController = SplashScreenRecentDocumentViewController()
      viewController.url = projectURL
      recentDocumentViewControllers.append(viewController)
    }

    return recentDocumentViewControllers
  }

}

extension SplashScreenWindowController:  NSTableViewDelegate, NSTableViewDataSource {

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    return recentDocumentViewControllers[row].view
  }

  func numberOfRows(in tableView: NSTableView) -> Int {
    return recentDocumentViewControllers.count
  }

}
