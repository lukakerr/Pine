//
//  SwiftAST.swift
//  CommonMark
//
//  Created by Chris Eidhof on 22/05/15.
//  Copyright (c) 2015 Unsigned Integer. All rights reserved.
//

import Foundation
import cmark_gfm

/// The type of a list in Markdown, represented by `Block.List`.
public enum ListType {
    case unordered
    case ordered
}

/// An inline element in a Markdown abstract syntax tree.
public enum Inline {
    case text(text: String)
    case softBreak
    case lineBreak
    case code(text: String)
    case html(text: String)
    case emphasis(children: [Inline])
    case strong(children: [Inline])
    case custom(literal: String)
    case link(children: [Inline], title: String?, url: String?)
    case image(children: [Inline], title: String?, url: String?)
    case strikethrough(children: [Inline])
    case mention(login: String)
    case checkbox(checked: Bool, originalRange: NSRange)
}

enum InlineType: String {
    case code
    case custom_inline
    case emph
    case html_inline
    case image
    case linebreak
    case link
    case softbreak
    case strong
    case text
    case strikethrough
    case mention
    case checkbox
}

extension Inline: ExpressibleByStringLiteral {
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public init(stringLiteral: StringLiteralType) {
        self = Inline.text(text: stringLiteral)
    }
}

/// A block-level element in a Markdown abstract syntax tree.
public enum Block {
    case list(items: [[Block]], type: ListType)
    case blockQuote(items: [Block])
    case codeBlock(text: String, language: String?)
    case html(text: String)
    case paragraph(text: [Inline])
    case heading(text: [Inline], level: Int)
    case custom(literal: String)
    case thematicBreak
    case table(items: [Block])
    case tableHeader(items: [Block])
    case tableRow(items: [Block])
    case tableCell(items: [Inline])
}

enum BlockType: String {
    case block_quote
    case code_block
    case custom_block
    case heading
    case html_block
    case list
    case paragraph
    case table
    case table_cell
    case table_header
    case table_row
    case thematic_break
}

extension Inline {
    init?(_ node: Node) {
        guard let type = InlineType(rawValue: node.typeString) else {
            return nil
        }
        let inlineChildren = { node.children.compactMap(Inline.init) }
        switch type {
        case .text:
            self = .text(text: node.literal!)
        case .softbreak:
            self = .softBreak
        case .linebreak:
            self = .lineBreak
        case .code:
            self = .code(text: node.literal!)
        case .html_inline:
            self = .html(text: node.literal!)
        case .custom_inline:
            self = .custom(literal: node.literal!)
        case .emph:
            self = .emphasis(children: inlineChildren())
        case .strong:
            self = .strong(children: inlineChildren())
        case .link:
            self = .link(children: inlineChildren(), title: node.title, url: node.urlString)
        case .image:
            self = .image(children: inlineChildren(), title: node.title, url: node.urlString)
        case .strikethrough:
            self = .strikethrough(children: inlineChildren())
        case .mention:
            self = .mention(login: node.login ?? "")
        case .checkbox:
            self = .checkbox(checked: node.checked, originalRange: node.checkedRange)
        }
    }
}

extension Block {
    init?(_ node: Node) {
        guard let type = BlockType(rawValue: node.typeString) else {
            return nil
        }
        let parseInlineChildren = { node.children.compactMap(Inline.init) }
        let parseBlockChildren = { node.children.compactMap(Block.init) }
        switch type {
        case .paragraph:
            self = .paragraph(text: parseInlineChildren())
        case .block_quote:
            self = .blockQuote(items: parseBlockChildren())
        case .list:
            let type: ListType = node.listType == CMARK_BULLET_LIST ? .unordered : .ordered
            self = .list(items: node.children.compactMap { $0.listItem }, type: type)
        case .code_block:
            self = .codeBlock(text: node.literal!, language: node.fenceInfo)
        case .html_block:
            self = .html(text: node.literal!)
        case .custom_block:
            self = .custom(literal: node.literal!)
        case .heading:
            self = .heading(text: parseInlineChildren(), level: node.headerLevel)
        case .thematic_break:
            self = .thematicBreak
        case .table:
            self = .table(items: parseBlockChildren())
        case .table_header:
            self = .tableHeader(items: parseBlockChildren())
        case .table_row:
            self = .tableRow(items: parseBlockChildren())
        case .table_cell:
            self = .tableCell(items: parseInlineChildren())
        }
    }
}

extension Node {
    var listItem: [Block]? {
        switch type {
        case CMARK_NODE_ITEM:
            return children.compactMap(Block.init)
        default:
            return nil
        }
    }

}

extension Node {
    convenience init(type: cmark_node_type, children: [Node] = []) {
        self.init(node: cmark_node_new(type))
        for child in children {
            cmark_node_append_child(node, child.node)
        }
    }
}

//extension Node {
//    convenience init(type: cmark_node_type, literal: String) {
//        self.init(type: type)
//        self.literal = literal
//    }
//    convenience init(type: cmark_node_type, blocks: [Block]) {
//        self.init(type: type, children: blocks.map(Node.init))
//    }
//    convenience init(type: cmark_node_type, elements: [Inline]) {
//        self.init(type: type, children: elements.map(Node.init))
//    }
//}

//extension Node {
//    public convenience init(blocks: [Block]) {
//        self.init(type: CMARK_NODE_DOCUMENT, blocks: blocks)
//    }
//}

extension Node {
    /// The abstract syntax tree representation of a Markdown document.
    /// - returns: an array of block-level elements.
    public var elements: [Block] {
        return children.compactMap(Block.init)
    }
}

func tableOfContents(document: String) -> [Block] {
    let blocks = Node(markdown: document)?.children.compactMap(Block.init) ?? []
    return blocks.filter {
        switch $0 {
        case .heading(_, let level) where level < 3: return true
        default: return false
        }
    }
}

//extension Node {
//    convenience init(element: Inline) {
//        switch element {
//        case .text(let text):
//            self.init(type: CMARK_NODE_TEXT, literal: text)
//        case .emphasis(let children):
//            self.init(type: CMARK_NODE_EMPH, elements: children)
//        case .code(let text):
//            self.init(type: CMARK_NODE_CODE, literal: text)
//        case .strong(let children):
//            self.init(type: CMARK_NODE_STRONG, elements: children)
//        case .html(let text):
//            self.init(type: CMARK_NODE_HTML_INLINE, literal: text)
//        case .custom(let literal):
//            self.init(type: CMARK_NODE_CUSTOM_INLINE, literal: literal)
//        case let .link(children, title, url):
//            self.init(type: CMARK_NODE_LINK, elements: children)
//            self.title = title
//            self.urlString = url
//        case let .image(children, title, url):
//            self.init(type: CMARK_NODE_IMAGE, elements: children)
//            self.title = title
//            urlString = url
//        case .softBreak:
//            self.init(type: CMARK_NODE_SOFTBREAK)
//        case .lineBreak:
//            self.init(type: CMARK_NODE_LINEBREAK)
//        }
//    }
//}
//
//extension Node {
//    convenience init(block: Block) {
//        switch block {
//        case .paragraph(let children):
//            self.init(type: CMARK_NODE_PARAGRAPH, elements: children)
//        case let .list(items, type):
//            let listItems = items.map { Node(type: CMARK_NODE_ITEM, blocks: $0) }
//            self.init(type: CMARK_NODE_LIST, children: listItems)
//            listType = type == .Unordered ? CMARK_BULLET_LIST : CMARK_ORDERED_LIST
//        case .blockQuote(let items):
//            self.init(type: CMARK_NODE_BLOCK_QUOTE, blocks: items)
//        case let .codeBlock(text, language):
//            self.init(type: CMARK_NODE_CODE_BLOCK, literal: text)
//            fenceInfo = language
//        case .html(let text):
//            self.init(type: CMARK_NODE_HTML_BLOCK, literal: text)
//        case .custom(let literal):
//            self.init(type: CMARK_NODE_CUSTOM_BLOCK, literal: literal)
//        case let .heading(text, level):
//            self.init(type: CMARK_NODE_HEADING, elements: text)
//            headerLevel = level
//        case .thematicBreak:
//            self.init(type: CMARK_NODE_THEMATIC_BREAK)
//        }
//    }
//}

