//
//  PreferenceCategory.swift
//  Pine
//
//  Created by Luka Kerr on 1/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Foundation

enum PreferenceCategory: String, CaseIterable {
  case general = "General"
  case ui = "UI"
  case editor = "Editor"
  case preview = "Preview"
  case markdown = "Markdown"
  case document = "Document"

  static let categories = [
    general,
    ui,
    editor,
    preview,
    markdown,
    document
  ]
}
