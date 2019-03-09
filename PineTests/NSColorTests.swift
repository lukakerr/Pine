//
//  NSColorTests.swift
//  PineTests
//
//  Created by Luka Kerr on 10/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import XCTest
@testable import Pine

class NSColorTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testIsDark() {
    let color = NSColor.black

    XCTAssertTrue(color.isDark)
  }

  func testIsNotDark() {
    let color = NSColor.white

    XCTAssertFalse(color.isDark)
  }

  func testGetHexWhite() {
    let color = NSColor.white
    let hex = color.hex

    XCTAssertEqual(hex, "#FFFFFF")
  }

  func testGetHexRed() {
    let color = NSColor.red
    let hex = color.hex

    XCTAssertEqual(hex, "#FF0000")
  }

  func testGetLighter() {
    let color = NSColor.red
    let lighter = color.lighter

    let expected = NSColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 0)

    XCTAssertEqual(lighter, expected)
  }

  func testGetLighterWhite() {
    let color = NSColor.white
    let lighter = color.lighter

    let expected = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)

    XCTAssertEqual(lighter, expected)
  }

  func testGetDarker() {
    let color = NSColor.blue
    let darker = color.darker

    let expected = NSColor(red: 0.0, green: 0.0, blue: 0.975, alpha: 0)

    XCTAssertEqual(darker, expected)
  }

  func testGetDarkerBlack() {
    let color = NSColor.black
    let darker = color.darker

    let expected = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0)

    XCTAssertEqual(darker, expected)
  }

}
