//
//  Block+TextElement.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/31/18.
//

import Foundation

extension Block {
    var textElements: [TextElement]? {
        if case .paragraph(let text) = self {
            return text.textElements
        }
        return nil
    }
}

extension Sequence where Iterator.Element == Block {
    var textElements: [[TextElement]] { return compactMap { $0.textElements } }
}
