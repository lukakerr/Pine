//
//  Block+ListElement.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/31/18.
//

import Foundation

extension Block {
    func listElement(_ level: Int) -> ListElement? {
        switch self {
        case .paragraph(let text):
            return .text(text: text.textElements)
        case .blockQuote(let items):
            return .text(text: items.textElements.flatMap { $0 })
        case .custom(let literal):
            return .text(text: [.text(text: literal)])
        case .codeBlock(let text, _):
            return .text(text: [.code(text: text)])
        case .list(let items, let type):
            let deeper = level + 1
            return .list(children: items.compactMap { $0.listElements(deeper) }, type: type, level: deeper)
        default: return nil
        }
    }
}

extension Sequence where Iterator.Element == Block {
    func listElements(_ level: Int) -> [ListElement] {
        return compactMap { $0.listElement(level) }
    }
}
