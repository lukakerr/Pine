//
//  Inline+TextElement.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/31/18.
//

import Foundation

extension Inline {
    var textElement: TextElement? {
        switch self {
        case .text(let text):
            return text.isEmpty ? nil : .text(text: text)
        case .softBreak:
            return .softBreak
        case .lineBreak:
            return .lineBreak
        case .code(let text):
            return text.isEmpty ? nil : .code(text: text)
        case .emphasis(let children):
            return .emphasis(children: children.compactMap { $0.textElement })
        case .strong(let children):
            return .strong(children: children.compactMap { $0.textElement })
        case .custom(let literal):
            return literal.isEmpty ? nil : .text(text: literal)
        case .link(let children, let title, let url):
            return .link(children: children.compactMap { $0.textElement }, title: title, url: url)
        case .strikethrough(let children):
            return .strikethrough(children: children.compactMap { $0.textElement })
        case .mention(let login):
            return .mention(login: login)
        case .checkbox(let checked, let originalRange):
            return .checkbox(checked: checked, originalRange: originalRange)
        case .image, .html:
            return nil
        }
    }
}

extension Sequence where Iterator.Element == Inline {
    var textElements: [TextElement] { return compactMap { $0.textElement } }
}
