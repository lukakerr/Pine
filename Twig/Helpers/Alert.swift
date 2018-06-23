//
//  Alert.swift
//  Twig
//
//  Created by Luka Kerr on 23/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class Alert {

  public static func display(_ message: String, title: String = "Error") {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.runModal()
  }

}
