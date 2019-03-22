//
//  MarkdownLayoutManager.swift
//  Pine
//
//  Created by Luka Kerr on 20/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

fileprivate struct InvisibleLines {
  let space: CTLine
  let tab: CTLine
  let newLine: CTLine
}

final class MarkdownLayoutManager: NSLayoutManager {

  private var baselineOffset: CGFloat = 0
  private lazy var invisibleLines = self.generateInvisibleLines()

  private var isRtl: Bool {
    return firstTextView?.baseWritingDirection == .rightToLeft
  }

  override init() {
    super.init()

    self.showsControlCharacters = false

    self.fontDidUpdate()
    self.invalidateDisplay()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  public func fontDidUpdate() {
    self.baselineOffset = self.defaultBaselineOffset(for: preferences.font)
    self.invisibleLines = self.generateInvisibleLines()
  }

  // MARK: Private methods

  private func invalidateDisplay() {
    guard let textStorage = textStorage else { return }
    self.invalidateDisplay(forCharacterRange: NSRange(..<textStorage.length))
  }

  private func generateInvisibleLines() -> InvisibleLines {
    return InvisibleLines(
      space: self.invisibleLine(.space, font: preferences.font),
      tab: self.invisibleLine(.tab, font: preferences.font),
      newLine: self.invisibleLine(.newLine, font: preferences.font)
    )
  }

  private func invisibleLine(_ invisible: Invisible, font: NSFont) -> CTLine {
    let glyphChar = invisible.getChar(isRtl: isRtl)
    return CTLine.create(string: glyphChar, color: .disabledControlTextColor, font: font)
  }

  // MARK: Layout Manager methods

  override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
    guard
      let string = textStorage?.string,
      let currentContext = NSGraphicsContext.current
    else { return }

    NSGraphicsContext.saveGraphicsState()

    if NSGraphicsContext.currentContextDrawingToScreen() {
      currentContext.shouldAntialias = true
    }

    let context = currentContext.cgContext

    if preferences[.showInvisibles] {
      if currentContext.isFlipped {
        context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0)
      }

      for glyphIndex in glyphsToShow.location..<glyphsToShow.upperBound {
        let line: CTLine
        let charIndex = characterIndexForGlyph(at: glyphIndex)
        let invisible = Invisible(char: string[charIndex])

        switch invisible {
        case .space?:
          line = self.invisibleLines.space

        case .tab?:
          line = self.invisibleLines.tab

        case .newLine?:
          line = self.invisibleLines.newLine

        default:
          continue
        }

        let lineOrigin = lineFragmentRect(
          forGlyphAt: glyphIndex,
          effectiveRange: nil,
          withoutAdditionalLayout: true
        ).origin

        let glyphLocation = location(forGlyphAt: glyphIndex)

        var point = lineOrigin
          .offset(by: origin)
          .offsetBy(dx: glyphLocation.x, dy: baselineOffset)

        if isRtl && invisible == .newLine {
          point.x -= line.bounds.width
        }

        context.textPosition = point
        CTLineDraw(line, context)
      }
    }

    super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)

    NSGraphicsContext.restoreGraphicsState()
  }

}
