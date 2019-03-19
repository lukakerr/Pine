//
//  ToolbarItemInfo.swift
//  Pine
//
//  Created by Luka Kerr on 19/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

struct ToolbarItemInfo {

  var title: String?
  var icon: NSImage.Name?
  var iconTitle: String?
  var action: Selector?
  var identifier: NSToolbarItem.Identifier

  init(identifier: NSToolbarItem.Identifier) {
    self.identifier = identifier
  }

  init(
    title: String,
    icon: NSImage.Name,
    action: Selector,
    identifier: NSToolbarItem.Identifier
  ) {
    self.init(identifier: identifier)
    self.title = title
    self.action = action
    self.icon = icon
  }

  init(
    title: String,
    iconTitle: String,
    action: Selector,
    identifier: NSToolbarItem.Identifier
  ) {
    self.init(identifier: identifier)
    self.title = title
    self.action = action
    self.iconTitle = iconTitle
  }

}
