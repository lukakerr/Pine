//
//  Character.swift
//  Pine
//
//  Created by Luka Kerr on 17/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Foundation

extension Character {

  public var isWhiteSpace: Bool { 
    return self == " " || self == "\n" || self == "\r" || self == "$"
  }

}
