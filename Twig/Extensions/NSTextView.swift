//
//  NSTextView.swift
//  Twig
//
//  Created by Luka Kerr on 27/10/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let PAIRABLE_CHARACTERS: [Character: Character] = [
  "[": "]",
  "(": ")",
  "*": "*",
  "_": "_",
  "`": "`",
  "$": "$",
  "'": "'",
  "\"": "\""
]

extension NSTextView {

  public var cursorLocation: Int {
    return self.selectedRange().location
  }

  /// Inserts the given left and right characters on either side of selected text,
  /// or creates a new string and inserts the cursor in the middle of it
  ///
  /// - Parameters:
  ///   - left: the left (optional) characters
  ///   - right: the right (optional) characters
  ///   - atLineStart: whether the left character should be inserted at the start of the line
  ///   - newLineIfSelected: whether to create a newline on the left and right if the text is selected
  public func replace(
    left: String? = nil,
    right: String? = nil,
    atLineStart: Bool = false,
    newLineIfSelected: Bool = false
  ) {
    if left == nil && right == nil {
      return
    }

    var leftText = left ?? ""
    var rightText = right ?? ""

    if newLineIfSelected {
      leftText = "\n\(leftText)"
      rightText = "\(rightText)\n"
    }

    let str = self.string as NSString

    var range = self.selectedRange()

    if atLineStart {
      range = str.lineRange(for: NSRange(location: range.location, length: 0))
    }

    let text = str.substring(with: range)

    let replacement = "\(leftText)\(text)\(rightText)"

    let newCursorPosition = cursorLocation + leftText.lengthOfBytes(using: .utf8)

    // Let NSTextView know we are going to make a replacement
    // This retains document history allowing for undo etc
    self.shouldChangeText(in: range, replacementString: replacement)

    // Make replacement in range (length of 0 if nothing selected)
    self.replaceCharacters(in: range, with: replacement)

    // Set cursor position to appropriate position if not replacing a selection
    // If replacing a selection, the cursor goes to the end of the replaced text
    if range.length == 0 {
      self.setSelectedRange(NSRange(location: newCursorPosition, length: 0))
    }
  }

  /// Inserts the given left and right characters on either side of selected text,
  /// or creates a new string and inserts the cursor in the middle of it
  ///
  /// - Parameters:
  ///   - left: the left (optional) character
  ///   - right: the right (optional) character
  ///   - atLineStart: whether the left character should be inserted at the start of the line
  ///   - newLineIfSelected: whether to create a newline on the left and right if the text is selected
  public func replace(
    left: Character? = nil,
    right: Character? = nil,
    atLineStart: Bool = false,
    newLineIfSelected: Bool = false
  ) {
    var leftString: String? = nil
    var rightString: String? = nil

    if let l = left {
      leftString = String(l)
    }

    if let r = right {
      rightString = String(r)
    }

    self.replace(
      left: leftString,
      right: rightString,
      atLineStart: atLineStart,
      newLineIfSelected: newLineIfSelected
    )
  }

  /// Given a typed character, try to auto pair its match.
  /// Don't auto pair when there are characters to the left or right
  /// and when there is a text selection.
  ///
  /// Examples (| denotes cursor position):
  /// - Pair: "|"
  /// - Pair: "abc |"
  /// - Pair: "abc | "
  /// - No Pair: "abc| "
  /// - No Pair: "abc |e"
  ///
  /// - Parameters:
  ///   - character: the character typed to match with
  public func pair(character char: Character) {
    let match = PAIRABLE_CHARACTERS[char]

    if match == nil {
      return
    }

    let range = self.selectedRange()

    // For a selection, we don't pair
    if range.length != 0 {
      return
    }

    let length = self.string.count
    let str = self.string as NSString

    // If there exists a string
    if length > 0 {
      if cursorLocation > 0 {
        let prevRange = NSRange(location: cursorLocation - 1, length: 1)
        let prevChar = str.substring(with: prevRange)

        if !prevChar.isWhiteSpace {
          return
        }
      }

      // If there exists characters on the right hand side
      if cursorLocation < length {
        let nextRange = NSRange(location: cursorLocation, length: 1)
        let nextChar = str.substring(with: nextRange)

        if !nextChar.isWhiteSpace {
          return
        }
      }

    }

    self.replace(right: match)
  }
  
}
