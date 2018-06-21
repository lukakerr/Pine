//
//  NotificationCenter+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 21/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

extension NotificationCenter {
  
  static func send(_ key: String) {
    self.default.post(
      name: NSNotification.Name(rawValue: key),
      object: nil
    )
  }
  
  static func receive(_ key: String, instance: Any, selector: Selector) {
    self.default.addObserver(
      instance,
      selector: selector,
      name: NSNotification.Name(rawValue: key),
      object: nil
    )
  }
  
}
