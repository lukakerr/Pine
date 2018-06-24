//
//  OpenDocuments.swift
//  Twig
//
//  Created by Luka Kerr on 24/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

class OpenDocuments {

  static let sharedInstance = OpenDocuments()

  fileprivate var documents: [String]

  private init() {
    documents = []
  }

  public func addDocument(name: String) {
    documents.append(name)
  }

  public func getDocuments() -> [String] {
    return documents
  }

}

let openDocuments = OpenDocuments.sharedInstance
