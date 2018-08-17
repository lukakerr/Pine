//
//  Element.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/29/18.
//

import Foundation

public enum Element {
    case text(items: TextLine)
    case quote(items: TextLine, level: Int)
    case image(title: String, url: String)
    case html(text: String)
    case table(rows: [TableRow])
    case hr
    case codeBlock(text: String, language: String?)
    case heading(text: TextLine, level: Int)
    case list(items: [[ListElement]], type: ListType)
}
