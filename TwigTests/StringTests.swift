//
//  StringTests.swift
//  TwigTests
//
//  Created by Luka Kerr on 10/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import XCTest
@testable import Twig

class StringTexts: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testIsMarkdown() {
    let str = "MyFile.md"

    XCTAssertTrue(str.isMarkdown)
  }

  func testIsNotMarkdown() {
    let str = "MyFile.mda"

    XCTAssertFalse(str.isMarkdown)
  }

  func testIsBaseFile() {
    let file = "file:///"

    XCTAssertTrue(file.isBaseFile)
  }

  func testIsAlternativeBaseFile() {
    let file = "file://"

    XCTAssertTrue(file.isBaseFile)
  }

  func testIsNotBaseFile() {
    let file = "file:/"

    XCTAssertFalse(file.isBaseFile)
  }

  func testIsNotAlternativeBaseFile() {
    let file = "/"

    XCTAssertFalse(file.isBaseFile)
  }

  func testIsHttpsWebLink() {
    let link = "https://google.com"

    XCTAssertTrue(link.isWebLink)
  }

  func testIsHttpWebLink() {
    let link = "http://google.com"

    XCTAssertTrue(link.isWebLink)
  }

  func testIsNotWebLink() {
    let link = "ftp://google.com"

    XCTAssertFalse(link.isWebLink)
  }

}
