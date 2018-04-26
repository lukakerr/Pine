//
//  DownGroffRenderable.swift
//  Down
//
//  Created by Rob Phillips on 5/31/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation
import libcmark

public protocol DownGroffRenderable: DownRenderable {
    /**
     Generates a groff man string from the `markdownString` property

     - parameter options: `DownOptions` to modify parsing or rendering
     - parameter width:   The width to break on

     - throws: `DownErrors` depending on the scenario

     - returns: groff man string
     */
    
    func toGroff(_ options: DownOptions, width: Int32) throws -> String
}

public extension DownGroffRenderable {
    /**
     Generates a groff man string from the `markdownString` property

     - parameter options: `DownOptions` to modify parsing or rendering, defaulting to `.default`
     - parameter width:   The width to break on, defaulting to 0

     - throws: `DownErrors` depending on the scenario

     - returns: groff man string
     */
    
    public func toGroff(_ options: DownOptions = .default, width: Int32 = 0) throws -> String {
        let ast = try DownASTRenderer.stringToAST(markdownString, options: options)
        let groff = try DownGroffRenderer.astToGroff(ast, options: options, width: width)
        cmark_node_free(ast)
        return groff
    }
}

public struct DownGroffRenderer {
    /**
     Generates a groff man string from the given abstract syntax tree

     **Note:** caller is responsible for calling `cmark_node_free(ast)` after this returns

     - parameter options: `DownOptions` to modify parsing or rendering, defaulting to `.default`
     - parameter width:   The width to break on, defaulting to 0

     - throws: `ASTRenderingError` if the AST could not be converted

     - returns: groff man string
     */
    
    public static func astToGroff(_ ast: UnsafeMutablePointer<cmark_node>,
                                  options: DownOptions = .default,
                                  width: Int32 = 0) throws -> String {
        guard let cGroffString = cmark_render_man(ast, options.rawValue, width) else {
            throw DownErrors.astRenderingError
        }
        defer { free(cGroffString) }
        
        guard let groffString = String(cString: cGroffString, encoding: String.Encoding.utf8) else {
            throw DownErrors.astRenderingError
        }

        return groffString
    }
}
