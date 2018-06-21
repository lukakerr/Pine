//
//  TextElement.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/31/18.
//

import Foundation

public typealias TextLine = [TextElement]

public enum TextElement {
    case text(text: String)
    case softBreak
    case lineBreak
    case code(text: String)
    case emphasis(children: [TextElement])
    case strong(children: [TextElement])
    case link(children: [TextElement], title: String?, url: String?)
    case strikethrough(children: [TextElement])
    case mention(login: String)
    case checkbox(checked: Bool, originalRange: NSRange)
}
