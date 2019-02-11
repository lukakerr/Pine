//
//  DocumentController.swift
//  Twig
//
//  Created by Luka Kerr on 11/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

  override func openDocument(withContentsOf url: URL,
                             display displayDocument: Bool,
                             completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
    super.openDocument(
      withContentsOf: url,
      display: displayDocument,
      completionHandler: { (document, alreadyOpen, error) in
        // If there was an error or the file is already open, don't do anything
        guard error != nil && !alreadyOpen else { return }

        (NSApp.keyWindow?.windowController as? WindowController)?.syncWindowSidebars()
    });
  }

  // MARK: - Public static helper methods

  /// Try to open a markdown file given a URL.
  /// Accounts for both relative (to the currently open document) and absolute URL's
  public static func openMarkdownFile(withContentsOf url: URL) {
    guard let urlString = url.absoluteString.decodeURL() else { return }

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
      let currentDocument = WindowController.getCurrentDocument(),
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
