//
//  NSButton.swift
//  Pine
//
//  Created by Luka Kerr on 8/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

extension NSButton {

  var value: Bool {
    return self.state.rawValue.bool
  }

}
