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

    let range = self.selectedRange()

    var leftText = left ?? ""
    var rightText = right ?? ""

    if newLineIfSelected {
      leftText = "\n\(leftText)"
      rightText = "\(rightText)\n"
    }

    let text = (self.string as NSString).substring(with: range)

    let replacement = "\(leftText)\(text)\(rightText)"
    let cursorPosition = self.selectedRanges[0].rangeValue.location

    let newCursorPosition = cursorPosition + leftText.lengthOfBytes(using: .utf8)

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

    return self.replace(
      left: leftString,
      right: rightString,
      atLineStart: atLineStart,
      newLineIfSelected: newLineIfSelected
    )
  }

  /// Given a typed character, try to auto pair its match
  ///
  /// - Parameters:
  ///   - character: the character typed to match with
  public func pair(character char: Character) {
    let match = PAIRABLE_CHARACTERS[char]

    let cursorPosition = self.selectedRanges[0].rangeValue.location

    if cursorPosition > 0 {
      let prevRange = NSRange(location: cursorPosition - 1, length: 1)
      let prevChar = (self.string as NSString).substring(with: prevRange)

      if !prevChar.isWhiteSpace {
        return
      }
    }

    self.replace(right: match)
  }
  
}
