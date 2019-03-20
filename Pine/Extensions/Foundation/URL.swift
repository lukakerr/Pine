//
//  URL.swift
//  Pine
//
//  Created by Luka Kerr on 8/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Foundation

extension URL {

  /// Whether the URL is an image type
  public var isImage: Bool {
    guard let uti = UTTypeCreatePreferredIdentifierForTag(
      kUTTagClassFilenameExtension,
      pathExtension as CFString,
      nil
    )?.takeRetainedValue() else { return false }

    return UTTypeConformsTo(uti, kUTTypeImage)
  }

}
