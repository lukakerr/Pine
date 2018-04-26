//
//  DownLaTeXRenderable.swift
//  Down
//
//  Created by Rob Phillips on 5/31/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation
import libcmark

public protocol DownLaTeXRenderable: DownRenderable {
    /**
     Generates a LaTeX string from the `markdownString` property

     - parameter options: `DownOptions` to modify parsing or rendering
     - parameter width:   The width to break on

     - throws: `DownErrors` depending on the scenario

     - returns: LaTeX string
     */
    
    func toLaTeX(_ options: DownOptions, width: Int32) throws -> String
}

public extension DownLaTeXRenderable {
    /**
     Generates a LaTeX string from the `markdownString` property

     - parameter options: `DownOptions` to modify parsing or rendering, defaulting to `.default`
     - parameter width:   The width to break on, defaulting to 0

     - throws: `DownErrors` depending on the scenario

     - returns: LaTeX string
     */
    
    public func toLaTeX(_ options: DownOptions = .default, width: Int32 = 0) throws -> String {
        let ast = try DownASTRenderer.stringToAST(markdownString, options: options)
        let latex = try DownLaTeXRenderer.astToLaTeX(ast, options: options, width: width)
        cmark_node_free(ast)
        return latex
    }
}

public struct DownLaTeXRenderer {
    /**
     Generates a LaTeX string from the given abstract syntax tree

     **Note:** caller is responsible for calling `cmark_node_free(ast)` after this returns

     - parameter options: `DownOptions` to modify parsing or rendering, defaulting to `.default`
     - parameter width:   The width to break on, defaulting to 0

     - throws: `ASTRenderingError` if the AST could not be converted

     - returns: LaTeX string
     */
    
    public static func astToLaTeX(_ ast: UnsafeMutablePointer<cmark_node>,
                                  options: DownOptions = .default,
                                  width: Int32 = 0) throws -> String {
        guard let cLatexString = cmark_render_latex(ast, options.rawValue, width) else {
            throw DownErrors.astRenderingError
        }
        defer { free(cLatexString) }
        
        guard let latexString = String(cString: cLatexString, encoding: String.Encoding.utf8) else {
            throw DownErrors.astRenderingError
        }
        
        return latexString
    }
}
