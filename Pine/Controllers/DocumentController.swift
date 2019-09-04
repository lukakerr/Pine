//
//  DocumentController.swift
//  Pine
//
//  Created by Luka Kerr on 11/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

  private let documentLock = NSLock()
  private var deferredDocuments = [NSDocument]()

  private var currentWindowController: PineWindowController? {
    return NSApp.keyWindow?.windowController as? PineWindowController
  }

  private var transientDocumentToReplace: Document? {
    let document = currentDocumentToReplace

    guard
      document?.isTransient ?? false,
      document?.windowForSheet?.attachedSheet == nil
    else { return nil }

    return document
  }

  private var currentDocumentToReplace: Document? {
    return currentWindowController?.document as? Document
  }

  override func openDocument(
    withContentsOf url: URL,
    display displayDocument: Bool,
    completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void
  ) {
    self.documentLock.lock()

    let transientDocument = self.transientDocumentToReplace

    if let transientDocument = transientDocument {
      transientDocument.isTransient = false
      self.deferredDocuments = []
    }

    self.documentLock.unlock()

    self.openAndReplaceDocument(
      for: url,
      toReplace: transientDocument,
      displayDocument: true,
      completionHandler: { document, alreadyOpen, error in
        // Ensure after opening a document that the splash screen window is closed
        for window in NSApp.windows {
          if let splashScreenWindow = window.windowController as? SplashScreenWindowController {
            splashScreenWindow.close()
          }
        }

        completionHandler(document, alreadyOpen, error)
      }
    )
  }

  /// Replace the currently opened document (if it exists) with the provided URL
  public func replaceCurrentDocument(with url: URL) {
    self.documentLock.lock()

    let currentDocument = self.currentDocumentToReplace

    if let currentDocument = currentDocument {
      currentDocument.savePresentedItemChanges(completionHandler: { _ in })
      self.deferredDocuments = []
    }

    self.documentLock.unlock()

    self.openAndReplaceDocument(
      for: url,
      toReplace: currentDocument,
      displayDocument: true,
      completionHandler: { _, _, _ in}
    )
  }

  /// Try to open a markdown file given a URL.
  /// Accounts for both relative (to the currently open document) and absolute URL's
  public func openMarkdownFile(withContentsOf url: URL) {
    guard let urlString = url.path.decoded else { return }

    // Case where absolute file exists
    if FileManager.default.fileExists(atPath: urlString) {
      // Convert to a file:// URL
      guard let fileAsURL = URL(string: String.FilePrefix + urlString) else { return }

      DocumentController.shared.openDocument(
        withContentsOf: fileAsURL,
        display: true,
        completionHandler: { _, _, _ in }
      )

      return
    }

    guard
      let currentDocument = PineWindowController.getCurrentDocument(),
      let currentPath = URL(string: currentDocument)?.deletingLastPathComponent()
    else { return }

    let filePath = currentPath.absoluteString + urlString

    // Case where relative file exists
    if FileManager.default.fileExists(atPath: filePath) {
      // Convert to a file:// URL
      guard let filePathURL = URL(string: String.FilePrefix + filePath) else { return }

      DocumentController.shared.openDocument(
        withContentsOf: filePathURL,
        display: true,
        completionHandler: { _, _, _ in }
      )

      return
    }
  }

  // MARK: - Private methods

  private func openAndReplaceDocument(
    for url: URL,
    toReplace: Document?,
    displayDocument: Bool,
    completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void
  ) {
    super.openDocument(withContentsOf: url, display: false) { (document, alreadyOpen, error) in
      if let toReplace = toReplace, let document = document as? Document {
        self.replaceDocument(toReplace, with: document)

        if displayDocument {
          document.makeWindowControllers()
          document.showWindows()
        }

        for deferredDocument in self.deferredDocuments {
          deferredDocument.makeWindowControllers()
          deferredDocument.showWindows()
        }

        self.deferredDocuments = []
      } else if let document = document {
        if self.deferredDocuments.isEmpty {
          document.makeWindowControllers()
          document.showWindows()
        } else {
          self.deferredDocuments.append(document)
        }
      }

      completionHandler(document, alreadyOpen, error)
    }
  }

  private func replaceDocument(_ document: Document, with replacement: Document) {
    guard Thread.isMainThread else { return }

    for controller in document.windowControllers {
      replacement.addWindowController(controller)
      document.removeWindowController(controller)
    }

    document.close()
  }

}
