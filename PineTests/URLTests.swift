//
//  URLTests.swift
//  PineTests
//
//  Created by Luka Kerr on 25/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import XCTest
@testable import Pine

class URLTests: XCTestCase {

  func testIsImage() {
    let url = URL(fileURLWithPath: "~/Desktop/pic.png")

    XCTAssertTrue(url.isImage)
  }

  func testIsRelativeImage() {
    let url = URL(fileURLWithPath: "../../image.jpeg")

    XCTAssertTrue(url.isImage)
  }

  func testIsNotImage() {
    let url = URL(fileURLWithPath: "./file.txt")

    XCTAssertFalse(url.isImage)
  }

}

