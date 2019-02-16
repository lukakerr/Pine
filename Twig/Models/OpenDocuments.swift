//
//  OpenDocuments.swift
//  Twig
//
//  Created by Luka Kerr on 24/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

final class OpenDocuments {

  static let sharedInstance = OpenDocuments()
  fileprivate var documents: [FileSystemItem]

  private init() {
    documents = []
  }

  /// Add a FileSystemItem to the open documents
  public func addDocument(_ doc: FileSystemItem) {
    // Doesn't already exist
    if !contains(doc) {
      documents.append(doc)
    }
  }

  /// Remove an item from the open documents given a URL
  public func removeDocument(with url: URL) {
    if let index = documents.index(where: { $0.fullPath == url.relativePath }) {
      documents.remove(at: index)
    }
  }

  /// Returns whether the FileSystemItem given exists in the open documents
  public func contains(_ doc: FileSystemItem) -> Bool {
    return documents.contains(where: { $0.fullPath == doc.fullPath })
  }

  /// Get all open documents
  public func getDocuments() -> [FileSystemItem] {
    return documents
  }

}

let openDocuments = OpenDocuments.sharedInstance
