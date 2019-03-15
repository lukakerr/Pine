//
//  MenuItemUITests.swift
//  PineUITests
//
//  Created by Luka Kerr on 15/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import XCTest

class MenuItemUITests: XCTestCase {

  override func setUp() {
    super.setUp()

    // Stop immediately when a failure occurs
    continueAfterFailure = false

    // Launch the application
    XCUIApplication().launch()
  }

  func testToggleSidebar() {
    let app = XCUIApplication()
    let viewMenu = app.menuBarItems.element(boundBy: 4)

    let sidebar = app.splitGroups.firstMatch

    XCTAssertTrue(sidebar.isHittable)

    let hideSidebarPredicate = NSPredicate(format: "title = %@", "Hide Sidebar")
    let hideSidebarMenu = viewMenu.menuItems.element(matching: hideSidebarPredicate)

    hideSidebarMenu.click()

    XCTAssertFalse(sidebar.isHittable)

    let showSidebarPredicate = NSPredicate(format: "title = %@", "Show Sidebar")
    let showSidebarMenu = viewMenu.menuItems.element(matching: showSidebarPredicate)

    showSidebarMenu.click()

    XCTAssertTrue(sidebar.isHittable)
  }

  func testTogglePreview() {
    let app = XCUIApplication()
    let viewMenu = app.menuBarItems.element(boundBy: 4)

    let preview = app.splitGroups.element(boundBy: 1)

    XCTAssertTrue(preview.isHittable)

    let togglePreviewPredicate = NSPredicate(format: "title = %@", "Toggle Preview")
    let togglePreviewMenu = viewMenu.menuItems.element(matching: togglePreviewPredicate)

    togglePreviewMenu.click()

    XCTAssertFalse(preview.isHittable)

    togglePreviewMenu.click()

    XCTAssertTrue(preview.isHittable)
  }

  func testToggleEditor() {
    let app = XCUIApplication()
    let viewMenu = app.menuBarItems.element(boundBy: 4)
    let editor = app.textViews.firstMatch

    XCTAssertTrue(editor.isHittable)

    let toggleEditorPredicate = NSPredicate(format: "title = %@", "Toggle Editor")
    let toggleEditorMenu = viewMenu.menuItems.element(matching: toggleEditorPredicate)

    toggleEditorMenu.click()

    XCTAssertFalse(editor.isHittable)

    toggleEditorMenu.click()

    XCTAssertTrue(editor.isHittable)
  }

  func testShowReference() {
    let app = XCUIApplication()
    let viewMenu = app.menuBarItems.element(boundBy: 4)

    XCTAssertEqual(app.windows.count, 1)

    let showReferencePredicate = NSPredicate(format: "title = %@", "Show Reference")
    let showReferenceMenu = viewMenu.menuItems.element(matching: showReferencePredicate)

    showReferenceMenu.click()

    XCTAssertEqual(app.windows.count, 2)

    app.typeKey("w", modifierFlags: .command)

    XCTAssertEqual(app.windows.count, 1)
  }

}
