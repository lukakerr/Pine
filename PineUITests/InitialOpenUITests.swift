//
//  InitialOpenUITests
//  PineUITests
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import XCTest

class InitialOpenUITests: XCTestCase {

  override func setUp() {
    super.setUp()

    // Stop immediately when a failure occurs
    continueAfterFailure = false

    // Launch the application
    XCUIApplication().launch()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testEmptyTextViewOpened() {
    let app = XCUIApplication()
    let textview = app.textViews.firstMatch
    let contents = textview.value as? String

    XCTAssertEqual(contents, "")
  }

  func testEmptyWebViewOpened() {
    let app = XCUIApplication()
    let webView = app.webViews.firstMatch
    let contents = webView.value as? String

    XCTAssertEqual(contents, "")
  }

  func testEmptySidebarOpened() {
    let app = XCUIApplication()
    let outlineViews = app.outlines.firstMatch
    let numberOfRows = outlineViews.outlineRows.count

    XCTAssertEqual(numberOfRows, 0)
  }

  func testUntitledDocumentOpened() {
    let app = XCUIApplication()
    let window = app.windows.firstMatch
    let title = window.title

    XCTAssertEqual(title, "Untitled")
  }

}
