//
//  OpenDocuments.swift
//  Twig
//
//  Created by Luka Kerr on 24/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

enum SidebarDocumentType {
  case file
  case header
  case folder
}

struct SidebarDocument {
  var url: URL?
  var name: String
  var type: SidebarDocumentType

  public init(url: URL?, name: String, type: SidebarDocumentType) {
    self.url = url
    self.name = name
    self.type = type
  }
}

class OpenDocuments {

  static let sharedInstance = OpenDocuments()

  fileprivate var documents: [SidebarDocument]

  private init() {
    let header = SidebarDocument(url: nil, name: "OPEN FILES", type: .header)
    documents = [header]
  }

  public func addDocument(_ doc: SidebarDocument) {
    documents.append(doc)
  }

  public func removeDocument(with url: URL) {
    if let index = documents.index(where: {$0.url == url}) {
      documents.remove(at: index)
    }
  }

  public func getDocuments() -> [SidebarDocument] {
    return documents
  }

}

let openDocuments = OpenDocuments.sharedInstance
