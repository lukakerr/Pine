//
//  CGPoint.swift
//  Pine
//
//  Created by Luka Kerr on 20/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

extension CGPoint {

  public func offsetBy(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
    return CGPoint(x: self.x + dx, y: self.y + dy)
  }

  public func offset(by point: CGPoint) -> CGPoint {
    return self.offsetBy(dx: point.x, dy: point.y)
  }

}
