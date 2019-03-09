//
//  Bool.swift
//  Pine
//
//  Created by Luka Kerr on 1/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

extension Bool {

  var state: NSControl.StateValue {
    return self ? .on : .off
  }

}
