//
//  Alert.swift
//  Twig
//
//  Created by Luka Kerr on 23/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class Alert {

  private static func run(
    message: String,
    title: String,
    style: NSAlert.Style
  ) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.runModal()
  }

  public static func error(message: String, title: String = "Error") {
    Alert.run(message: message, title: title, style: .warning)
  }

  public static func success(message: String, title: String = "Success") {
    Alert.run(message: message, title: title, style: .informational)
  }

}
