//
//  CommonMark.swift
//  CommonMark
//
//  Created by Chris Eidhof on 22/05/15.
//  Copyright (c) 2015 Unsigned Integer. All rights reserved.
//

import Foundation
import cmark_gfm

public func markdownToHtml(string: String) -> String {
    let outString = cmark_markdown_to_html(string, string.utf8.count, 0)!
    defer { free(outString) }
    return String(cString: outString)
}

struct Markdown {
    var string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    var html: String {
        let outString = cmark_markdown_to_html(string, string.utf8.count, 0)!
        return String(cString: outString)
    }
}

extension String {
    init?(unsafeCString: UnsafePointer<Int8>!) {
        guard let cString = unsafeCString else { return nil }
        self.init(cString: cString)
    }
}

public struct MarkdownOptions: OptionSet {
  public let rawValue: Int32

  public init(rawValue: Int32) {
    self.rawValue = rawValue
  }

  public static let footnotes = MarkdownOptions(rawValue: CMARK_OPT_FOOTNOTES)
}

public struct MarkdownExtensions: OptionSet {
  public let rawValue: Int32

  public init(rawValue: Int32) {
    self.rawValue = rawValue
  }

  public static let emoji = MarkdownExtensions(rawValue: 1 << 0)
  public static let table = MarkdownExtensions(rawValue: 1 << 1)
  public static let mention = MarkdownExtensions(rawValue: 1 << 2)
  public static let checkbox = MarkdownExtensions(rawValue: 1 << 3)
  public static let wikilink = MarkdownExtensions(rawValue: 1 << 4)
  public static let autolink = MarkdownExtensions(rawValue: 1 << 5)
  public static let strikethrough = MarkdownExtensions(rawValue: 1 << 6)

  public static let all: [MarkdownExtensions] = [
    .emoji, .table, .mention, .wikilink,
    .checkbox, .autolink, .strikethrough
  ]
}

/// A node in a Markdown document.
///
/// Can represent a full Markdown document (i.e. the document's root node) or
/// just some part of a document.
public class Node: CustomStringConvertible {
    let node: UnsafeMutablePointer<cmark_node>
    
    init(node: UnsafeMutablePointer<cmark_node>) {
        self.node = node
    }

    public init?(
      markdown: String,
      options: [MarkdownOptions] = [],
      extensions: [MarkdownExtensions] = MarkdownExtensions.all
    ) {
        core_extensions_ensure_registered()

        var parserOptions = options.reduce(CMARK_OPT_DEFAULT, { (acc, op) in
            acc | op.rawValue
        })

        guard let parser = cmark_parser_new(parserOptions) else { return nil }
        defer { cmark_parser_free(parser) }

        if extensions.contains(.table), let ext = cmark_find_syntax_extension("table") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        if extensions.contains(.autolink), let ext = cmark_find_syntax_extension("autolink") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        if extensions.contains(.strikethrough), let ext = cmark_find_syntax_extension("strikethrough") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        if extensions.contains(.mention), let ext = cmark_find_syntax_extension("mention") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        if extensions.contains(.checkbox), let ext = cmark_find_syntax_extension("checkbox") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        if extensions.contains(.emoji), let ext = cmark_find_syntax_extension("emoji") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        if extensions.contains(.wikilink), let ext = cmark_find_syntax_extension("wikilink") {
            cmark_parser_attach_syntax_extension(parser, ext)
        }

        cmark_parser_feed(parser, markdown, markdown.utf8.count)
        guard let node = cmark_parser_finish(parser) else { return nil }
        self.node = node
    }
    
    deinit {
        guard type == CMARK_NODE_DOCUMENT else { return }
        cmark_node_free(node)
    }
    
    var type: cmark_node_type {
        return cmark_node_get_type(node)
    }
    
    var listType: cmark_list_type {
        get { return cmark_node_get_list_type(node) }
        set { cmark_node_set_list_type(node, newValue) }
    }
    
    var listStart: Int {
        get { return Int(cmark_node_get_list_start(node)) }
        set { cmark_node_set_list_start(node, Int32(newValue)) }
    }
    
    var typeString: String {
        return String(cString: cmark_node_get_type_string(node)!)
    }
    
    var literal: String? {
        get { return String(unsafeCString: cmark_node_get_literal(node)) }
        set {
          if let value = newValue {
              cmark_node_set_literal(node, value)
          } else {
              cmark_node_set_literal(node, nil)
          }
        }
    }
    
    var headerLevel: Int {
        get { return Int(cmark_node_get_heading_level(node)) }
        set { cmark_node_set_heading_level(node, Int32(newValue)) }
    }

    var login: String? {
        return String(unsafeCString: cmark_node_get_mention_login(node))
    }

    var checked: Bool {
        return cmark_node_get_checkbox_checked(node) == 1
    }

    var checkedRange: NSRange {
        return NSRange(
            location: Int(cmark_node_get_checkbox_location(node)),
            length: Int(cmark_node_get_checkbox_length(node))
        )
    }
    
    var fenceInfo: String? {
        get {
            return String(unsafeCString: cmark_node_get_fence_info(node)) }
        set {
          if let value = newValue {
              cmark_node_set_fence_info(node, value)
          } else {
              cmark_node_set_fence_info(node, nil)
          }
        }
    }
    
    var urlString: String? {
        get { return String(unsafeCString: cmark_node_get_url(node)) }
        set {
          if let value = newValue {
              cmark_node_set_url(node, value)
          } else {
              cmark_node_set_url(node, nil)
          }
        }
    }
    
    var title: String? {
        get { return String(unsafeCString: cmark_node_get_title(node)) }
        set {
          if let value = newValue {
              cmark_node_set_title(node, value)
          } else {
              cmark_node_set_title(node, nil)
          }
        }
    }
    
    var children: [Node] {
        var result: [Node] = []
        
        var child = cmark_node_first_child(node)
        while let unwrapped = child {
            result.append(Node(node: unwrapped))
            child = cmark_node_next(child)
        }
        return result
    }

    /// Renders the HTML representation
    public var html: String {
        return String(cString: cmark_render_html(node, 0, nil))
    }
    
    /// Renders the XML representation
    public var xml: String {
        return String(cString: cmark_render_xml(node, 0))
    }
    
    /// Renders the CommonMark representation
    public var commonMark: String {
        return String(cString: cmark_render_commonmark(node, CMARK_OPT_DEFAULT, 80))
    }
    
    /// Renders the LaTeX representation
    public var latex: String {
        return String(cString: cmark_render_latex(node, CMARK_OPT_DEFAULT, 80))
    }

    public var description: String {
        return "\(typeString) {\n \(literal ?? String())\(Array(children).description) \n}"
    }
}
