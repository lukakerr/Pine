//
//  SplashScreenRecentDocumentViewController.swift
//  Pine
//
//  Created by Luka Kerr on 29/8/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

/// View controller for the "recent document" rows in the tableview in the splash screen.
final class SplashScreenRecentDocumentViewController: NSViewController {

  var url: URL?

  @IBOutlet weak var icon: NSImageView!
  @IBOutlet weak var filename: NSTextField!
  @IBOutlet weak var path: NSTextField!

  override var nibName: NSNib.Name? {
    return NSNib.Name( "SplashScreenRecentDocumentView")
  }

  override func viewDidLoad() {
    guard let url = url else { return }
    icon.image = NSImage(named: "File")
    filename.stringValue = (url.lastPathComponent as NSString).deletingPathExtension
    path.stringValue = ((url.path as NSString).deletingLastPathComponent as NSString).abbreviatingWithTildeInPath
  }

}
