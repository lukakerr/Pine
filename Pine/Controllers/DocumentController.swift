//
//  DocumentController.swift
//  Pine
//
//  Created by Luka Kerr on 11/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

  override func openDocument(withContentsOf url: URL,
                             display displayDocument: Bool,
                             completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
    guard let currentWindowController = Utils.getCurrentMainWindowController() else { return }

    let currentDocument = currentWindowController.document as? Document
    let isTransient = currentDocument?.isTransient ?? false

    // Is transient, so replace
    if isTransient {
      DocumentController.replaceCurrentDocument(with: url)
    } else {
      super.openDocument(
        withContentsOf: url,
        display: true,
        completionHandler: { _,_,_  in }
      );
    }

    currentWindowController.syncWindowSidebars()
  }

  // MARK: - Public static helper methods

  /// Replace the currently opened document (if it exists) with the provided URL
  public static func replaceCurrentDocument(with url: URL) {
    guard let currentWindowController = Utils.getCurrentMainWindowController() else { return }

    if let doc = currentWindowController.document as? Document {
      try? doc.read(from: url, ofType: url.pathExtension)
    }
  }

  /// Try to open a markdown file given a URL.
  /// Accounts for both relative (to the currently open document) and absolute URL's
  public static func openMarkdownFile(withContentsOf url: URL) {
    guard let urlString = url.path.decoded else { return }

    // Case where absolute file exists
    if FileManager.default.fileExists(atPath: urlString) {
      // Convert to a file:// URL
      guard let fileAsURL = URL(string: String.FilePrefix + urlString) else { return }

      DocumentController.shared.openDocument(
        withContentsOf: fileAsURL,
        display: true,
        completionHandler: { _,_,_ in }
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
        completionHandler: { _,_,_ in }
      )

      return
    }
  }

}
