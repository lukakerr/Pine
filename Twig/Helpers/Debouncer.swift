//
//  Debouncer.swift
//  Twig
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation

class Debouncer: NSObject {

  var callback: (() -> Void)
  var delay: Double
  weak var timer: Timer?

  init(delay: Double, callback: @escaping (() -> Void)) {
    self.delay = delay
    self.callback = callback
  }

  func call() {
    timer?.invalidate()
    let nextTimer = Timer.scheduledTimer(
      timeInterval: delay,
      target: self,
      selector: #selector(fire),
      userInfo: nil,
      repeats: false
    )
    timer = nextTimer
  }

  @objc func fire() {
    self.callback()
  }

}
