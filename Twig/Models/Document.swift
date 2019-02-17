//
//  Document.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class Document: NSDocument {

  fileprivate var markdownVC: MarkdownViewController?
  fileprivate var fileData: Data?

  /// Whether the document is transient.
  /// This is initially true until the document is modified
  public var isTransient: Bool = true

  override init() {
    super.init()
  }

  // Handles whether to autosave the document
  override class var autosavesInPlace: Bool {
    return preferences.autosaveDocument
  }

  // Handles changes from another application
  override func presentedItemDidChange() {
    guard fileContentsDidChange() else { return }

    if !self.isDocumentEdited {
      DispatchQueue.main.async {
        self.reloadFromFile()
      }
    }
  }

  // Can read document on a background thread
  override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {
    return true
  }

  // Creates a new window controller with the document being opened
  override func makeWindowControllers() {
    // Returns the Storyboard that contains your Document window.
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let windowController = storyboard.instantiateController(
      withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")
    ) as! NSWindowController
    self.markdownVC = windowController.contentViewController?.children.last?.children.first as? MarkdownViewController
    self.addWindowController(windowController)
    self.setContents()

    // Add opened document to sidebar
    if let url = self.fileURL {
      let parent = FileSystemItem.createParents(url: url)
      let newItem = FileSystemItem(path: url.absoluteString, parent: parent)
      openDocuments.addDocument(newItem)
    }

    if let wc = windowController as? WindowController {
      wc.syncWindowSidebars()
    }
  }

  // Returns data used to save the file
  override func data(ofType typeName: String) throws -> Data {
    guard let data = self.markdownVC?.textStorage.string.data(using: .utf8) else {
      throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    return data
  }

  // Reads from a file URL and updates the class variable fileData
  override func read(from url: URL, ofType typeName: String) throws {
    let contents = try? String(contentsOf: url, encoding: .utf8)
    self.fileData = contents?.data(using: .utf8)

    // Don't set contents if file hasn't changed
    if self.fileURL != url {
      self.setContents()
    }

    self.fileURL = url
  }

  override func updateChangeCount(_ change: NSDocument.ChangeType) {
    // Whenever the change count changes, the document is no longer transient
    self.isTransient = false

    super.updateChangeCount(change)
  }

  // MARK: - Private helper methods

  fileprivate func fileContentsDidChange() -> Bool {
    guard
      let canonicalModificationDate = self.fileModificationDate,
      let fileModificationDate = fileModificationDateOnDisk()
    else { return false }

    return fileModificationDate > canonicalModificationDate
  }

  fileprivate func fileModificationDateOnDisk() -> Date? {
    guard let fileURL = self.fileURL else { return nil }

    let fileAttrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
    let fileModificationDate = fileAttrs?[.modificationDate] as? Date
    return fileModificationDate
  }

  fileprivate func reloadFromFile() {
    if let fileURL = self.fileURL {
      try? self.read(from: fileURL, ofType: fileURL.pathExtension)
    }
    self.setContents()
  }

  fileprivate func setContents() {
    if let data = self.fileData, let contents = String(data: data, encoding: .utf8) {
      self.markdownVC?.textStorage.setAttributedString(NSAttributedString(string: contents))
    }
  }

}
