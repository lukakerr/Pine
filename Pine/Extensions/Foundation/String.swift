//
//  String+Extension.swift
//  Pine
//
//  Created by Luka Kerr on 1/7/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

extension String {

  static var FilePrefix = "file://"

  subscript (i: Int) -> Character {
    return self[index(startIndex, offsetBy: i)]
  }

  public var isMarkdown: Bool {
    return hasSuffix(".md") || hasSuffix(".markdown")
  }

  public var isBaseFile: Bool {
    return self == "file:///" || self == "file://"
  }

  public var isWebLink: Bool {
    return contains("http")
  }

  public var removingPercentEncoding: String {
    return self.removingPercentEncoding ?? self
  }

  public var isWhiteSpace: Bool {
    return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Decode URL and convert ~ to Home directory
  public var decoded: String? {
    let fileManager = FileManager.default

    return self
      .removingPercentEncoding?
      .replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path)
  }

}
