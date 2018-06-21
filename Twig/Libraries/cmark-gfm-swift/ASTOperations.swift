//
//  ASTOperations.swift
//  CommonMark
//
//  Created by Chris Eidhof on 23/05/15.
//  Copyright (c) 2015 Unsigned Integer. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == Block {
    /// Apply a transformation to each block-level element in the sequence.
    /// Performs a deep traversal of the element tree.
    ///
    /// - parameter f: The transformation function that will be recursively applied
    ///   to each block-level element in `elements`.
    ///
    ///   The function returns an array of elements, which allows you to transform
    ///   one element into several (or none). Return an array containing only the
    ///   unchanged element to not transform that element at all. Return an empty
    ///   array to delete an element from the result.
    /// - returns: A Markdown document containing the results of the transformation,
    ///   represented as an array of block-level elements.
    
    public func deepApply(_ f: (Block) throws -> [Block]) rethrows -> [Block] {
        return try flatMap { try $0.deepApply(f) }
    }
    
    /// Apply a transformation to each inline element in the sequence
    /// Performs a deep traversal of the element tree.
    ///
    /// - parameter f: The transformation function that will be recursively applied
    ///   to each inline element in `elements`.
    ///
    ///   The function returns an array of elements, which allows you to transform
    ///   one element into several (or none). Return an array containing only the
    ///   unchanged element to not transform that element at all. Return an empty
    ///   array to delete an element from the result.
    /// - returns: A Markdown document containing the results of the transformation,
    ///   represented as an array of block-level elements.
    public func deepApply(_ f: (Inline) throws -> [Inline]) rethrows -> [Block] {
        return try flatMap { try $0.deepApply(f) }
    }
}

extension Block {
    public func deepApply(_ f: (Block) throws -> [Block]) rethrows -> [Block]  {
        switch self {
        case let .list(items, type):
            let newItems = try items.map { item in try item.deepApply(f) }
            return try f(.list(items: newItems, type: type))
        case .blockQuote(let items):
            return try f(.blockQuote(items: try items.deepApply(f)))
        default:
            return try f(self)
        }
    }
    
    public func deepApply(_ f: (Inline) throws -> [Inline]) rethrows -> [Block] {
        switch self {
        case .paragraph(let children):
            return [.paragraph(text: try children.deepApply(f))]
        case let .list(items, type):
            return [.list(items: try items.map { try $0.deepApply(f) }, type: type)]
        case .blockQuote(let items):
            return [.blockQuote(items: try items.deepApply(f))]
        case let .heading(text, level):
            return [.heading(text: try text.deepApply(f), level: level)]
        default:
            return [self]
        }

    }
}

extension Sequence where Iterator.Element == Inline {
    public func deepApply(_ f: (Inline) throws -> [Inline]) rethrows -> [Inline] {
        return try flatMap { try $0.deepApply(f) }
    }
}


extension Inline {
    public func deepApply(_ f: (Inline) throws -> [Inline]) rethrows -> [Inline] {
        switch self {
        case .emphasis(let children):
            return try f(.emphasis(children: try children.deepApply(f)))
        case .strong(let children):
            return try f(Inline.strong(children: try children.deepApply(f)))
        case let .link(children, title, url):
            return try f(Inline.link(children: try children.deepApply(f), title: title, url: url))
        case let .image(children, title, url):
            return try f(Inline.image(children: try children.deepApply(f), title: title, url: url))
        default:
            return try f(self)
        }
    }
}


extension Sequence where Iterator.Element == Block {
    /// Performs a deep 'flatMap' operation over all _block-level elements_ in a
    /// sequence. Performs a deep traversal over all block-level elements
    /// in the element tree, applies `f` to each element, and returns the flattened
    /// results.
    ///
    /// Use this function to extract data from a Markdown document. E.g. you could
    /// extract the texts and levels of all headers in a document to build a table
    /// of contents.
    ///
    /// - parameter f: The function that will be recursively applied to each
    ///   block-level element in `elements`.
    ///
    ///   The function returns an array, which allows you to extract zero, one, or
    ///   multiple pieces of data from each element. Return an empty array to ignore
    ///   this element in the result.
    /// - returns: A flattened array of the results of all invocations of `f`.
    public func deep<A>(collect: (Block) throws -> [A]) rethrows -> [A] {
        return try flatMap { try $0.deep(collect: collect) }
    }
    
    public func deep<A>(collect: (Inline) throws -> [A]) rethrows -> [A] {
        return try flatMap { try $0.deep(collect: collect) }
    }
}

extension Block {    
    public func deep<A>(collect: (Block) throws -> [A]) rethrows -> [A] {
        var result: [A]
        switch self {
        case .list(let items, _):
            result = try items.joined().deep(collect: collect)
        case .blockQuote(let items):
            result = try items.deep(collect: collect)
        default:
            result = []
        }
        try result.append(contentsOf: collect(self))
        return result
    }
    
    public func deep<A>(collect: (Inline) throws -> [A]) rethrows -> [A] {
        var result: [A]
        switch self {
        case .list(let items, _):
            result = try items.joined().deep(collect: collect)
        case .blockQuote(let items):
            result = try items.deep(collect: collect)
        case .heading(let items, _):
            result = try items.deep(collect: collect)
        case .paragraph(let items):
            result = try items.deep(collect: collect)
        default:
            result = []
        }
        return result
    }
}

extension Inline {
    public func deep<A>(collect: (Inline) throws -> [A]) rethrows -> [A] {
        var result: [A]
        switch self {
        case .emphasis(let children):
            result = try children.deep(collect: collect)
        case .strong(let children):
            result = try children.deep(collect: collect)
        case let .link(children, _, _):
            result = try children.deep(collect: collect)
        case let .image(children, _, _):
            result = try children.deep(collect: collect)
        default:
            result = []
        }
        result.append(contentsOf: try collect(self))
        return result
    }
}

extension Sequence where Iterator.Element == Inline {
    public func deep<A>(collect: (Inline) throws -> [A]) rethrows -> [A] {
        return try flatMap { try $0.deep(collect: collect) }
    }
}
