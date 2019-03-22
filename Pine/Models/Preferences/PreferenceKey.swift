//
//  PreferenceKey.swift
//  Pine
//
//  Created by Luka Kerr on 8/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Foundation

public class PreferenceKeys {
  fileprivate init() {}
}

public class PreferenceKey<T>: PreferenceKeys {

  public let key: String
  public let defaultValue: T

  public init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

}
