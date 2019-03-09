//
//  SyntaxThemes.swift
//  Pine
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

struct SyntaxThemes {

  public static let ThemeList: [String] = getThemes()

  // Read theme file names from application support directory
  // This allows users to create their own themes
  private static func getThemes() -> [String] {
    if let supportFolder =  FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let stylesFolder = supportFolder.appendingPathComponent("highlight-js/styles")

      let contents = try? FileManager.default.contentsOfDirectory(
        at: stylesFolder,
        includingPropertiesForKeys: nil,
        options: []
      )

      if let cssFiles = contents?
        .filter({ $0.pathExtension == "css" })
        .map({ $0.deletingPathExtension().lastPathComponent })
        .sorted() { return cssFiles }
    }
    return []
  }

}
