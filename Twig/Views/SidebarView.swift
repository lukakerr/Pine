//
//  SidebarView.swift
//  Twig
//
//  Created by Luka Kerr on 1/7/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class SidebarView: NSOutlineView {

  // Draw custom disclosure images for outline view cell
  override func makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
    let view = super.makeView(withIdentifier: identifier, owner: owner)

    if identifier == NSOutlineView.disclosureButtonIdentifier {
      if let btnView = view as? NSButton {
        btnView.wantsLayer = true
        btnView.layer?.backgroundColor = .clear
//        btnView.image = NSImage(named: "RightArrow")
//        btnView.image?.size = NSSize(width: 14.0, height: 14.0)
//        btnView.alternateImage = NSImage(named: "DownArrow")
//        btnView.alternateImage?.size = NSSize(width: 14.0, height: 14.0)
      }
    }
    return view
  }

}
