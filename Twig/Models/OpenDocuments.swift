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

  public func addDocument(_ doc: FileSystemItem) {
    // Already exists
    if documents.index(where: { $0.fullPath == doc.fullPath }) != nil {
      return
    }

    documents.append(doc)
  }

  public func removeDocument(with url: URL) {
    if let index = documents.index(where: { $0.fullPath == url.relativePath }) {
      documents.remove(at: index)
    }
  }

  public func getDocuments() -> [FileSystemItem] {
    return documents
  }

}

let openDocuments = OpenDocuments.sharedInstance
