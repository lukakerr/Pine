//
//  String+ToHTML.swift
//  Down
//
//  Created by Rob Phillips on 6/1/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

import Foundation
import libcmark

extension String {

    /**
     Generates an HTML string from the contents of the string (self), which should contain CommonMark Markdown

     - parameter options: `DownOptions` to modify parsing or rendering, defaulting to `.default`

     - throws: `DownErrors` depending on the scenario

     - returns: HTML string
     */
    public func toHTML(_ options: DownOptions = .default) throws -> String {
        let ast = try DownASTRenderer.stringToAST(self, options: options)
        let html = try DownHTMLRenderer.astToHTML(ast, options: options)
        cmark_node_free(ast)
        return html
    }

}
