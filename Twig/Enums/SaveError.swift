//
//  SaveError.swift
//  Twig
//
//  Created by Luka Kerr on 1/7/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

enum SaveError: Error {
  case unableToWrite
  case URLNotFound
}

extension SaveError: CustomStringConvertible {
  var description: String {
    switch self {
    case .unableToWrite:
      return "Unable to write to file"
    case .URLNotFound:
      return "The file or directory cannot be found"
    }
  }
}
