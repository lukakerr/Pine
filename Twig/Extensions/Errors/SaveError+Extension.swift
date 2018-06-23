//
//  SaveError+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 23/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

extension SaveError: CustomStringConvertible {
  var description: String {
    switch self {
    case .unableToWrite:
      return "Unable to write to file"
    case .URLNotFound:
      return "Directory not found"
    }
  }
}
