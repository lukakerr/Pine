//
//  NotificationCenter+Extension.swift
//  Pine
//
//  Created by Luka Kerr on 21/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension NotificationCenter {

  static func send(_ key: Notification.Name) {
    self.default.post(
      name: key,
      object: nil
    )
  }

  static func receive(_ key: Notification.Name, instance: Any, selector: Selector) {
    self.default.addObserver(
      instance,
      selector: selector,
      name: key,
      object: nil
    )
  }

}

extension Notification.Name {
  static let preferencesChanged = Notification.Name("preferencesChanged")
  static let appearanceChanged = Notification.Name("appearanceChanged")
  static let scrollViewScrolled = NSView.boundsDidChangeNotification
}
