//
//  TwigTests.swift
//  TwigTests
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import XCTest
import Cocoa
@testable import Twig

class TextViewTests: XCTestCase {

  var textView: NSTextView!

  override func setUp() {
    super.setUp()

    textView = NSTextView()
  }

  override func tearDown() {
    textView = nil

    super.tearDown()
  }

  func testReplaceEmpty() {
    let contents = ""
    let range = NSRange(location: 0, length: 0)

    textView.insertText(contents, replacementRange: range)

    textView.replace(left: "**", right: "**")

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "****")
  }

  func testReplaceNewLineEmpty() {
    let contents = ""
    let range = NSRange(location: 0, length: 0)

    textView.insertText(contents, replacementRange: range)

    textView.replace(left: "```\n", right: "\n```", newLineIfSelected: true)

    let newContents = textView.textStorage?.string
    
    XCTAssert(newContents == "\n```\n\n```\n")
  }

  func testReplaceEmptyAtStart() {
    let contents = ""
    let range = NSRange(location: 0, length: 0)

    textView.insertText(contents, replacementRange: range)

    textView.replace(left: "##### ", atLineStart: true)

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "##### ")
  }

  func testReplaceSingleChar() {
    let contents = "a"
    let range = NSRange(location: 0, length: 1)

    textView.insertText(contents, replacementRange: range)
    textView.setSelectedRange(range)

    textView.replace(left: "$", right: "$")

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "$a$")
  }

  func testReplaceSingleCharNewline() {
    let contents = "a"
    let range = NSRange(location: 0, length: 1)

    textView.insertText(contents, replacementRange: range)
    textView.setSelectedRange(range)

    textView.replace(left: "$$\n", right: "\n$$", newLineIfSelected: true)

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "\n$$\na\n$$\n")
  }

  func testReplaceLine() {
    let contents = "a line of text in a text view"
    let range = NSRange(location: 0, length: contents.count)
     let selection = NSRange(location: 2, length: 4)

    textView.insertText(contents, replacementRange: range)
    textView.setSelectedRange(selection)

    textView.replace(left: "_", right: "_")

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "a _line_ of text in a text view")
  }

  func testReplaceMultipleLines() {
    let contents = "a line of text in a text view\nanother line of text\nand one more line"
    let range = NSRange(location: 0, length: contents.count)
    let selection = NSRange(location: 0, length: contents.count)

    textView.insertText(contents, replacementRange: range)
    textView.setSelectedRange(selection)

    textView.replace(left: "_", right: "_")

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "_\(contents)_")
  }

  func testReplaceMultipleLinesNewline() {
    let contents = "a line of text in a text view\nanother line of text\nand one more line"
    let range = NSRange(location: 0, length: contents.count)
    let selection = NSRange(location: 0, length: contents.count)

    textView.insertText(contents, replacementRange: range)
    textView.setSelectedRange(selection)

    textView.replace(left: "$$\n", right: "\n$$", newLineIfSelected: true)

    let newContents = textView.textStorage?.string

    XCTAssert(newContents == "\n$$\n\(contents)\n$$\n")
  }

}
