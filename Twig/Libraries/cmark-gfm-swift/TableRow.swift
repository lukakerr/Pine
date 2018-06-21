//
//  TableRow.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/31/18.
//

import Foundation

public enum TableRow {
    case header(cells: [TextLine])
    case row(cells: [TextLine])
}
