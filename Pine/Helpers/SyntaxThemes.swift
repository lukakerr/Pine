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

  // Read theme file names from resources directory
  private static func getThemes() -> [String] {
    if let stylesFolder = Bundle.main.path(forResource: "highlight-js/styles", ofType: nil) {
      let contents = try? FileManager.default.contentsOfDirectory(
        at: URL(fileURLWithPath: stylesFolder),
        includingPropertiesForKeys: nil,
        options: []
      )

      return contents?
        .filter({ $0.pathExtension == "css" })
        .map({ $0.deletingPathExtension().lastPathComponent })
        .sorted() ?? []
    }

    return []
  }

}
