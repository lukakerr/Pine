//
//  Block+TableRow.swift
//  cmark-gfm-swift
//
//  Created by Ryan Nystrom on 3/31/18.
//

import Foundation

extension Block {
    var tableCell: TextLine? {
        switch self {
        case .tableCell(let items): return items.textElements
        default: return nil
        }
    }
    var tableRow: TableRow? {
        switch self {
        case .tableRow(let items): return .row(cells: items.compactMap { $0.tableCell })
        case .tableHeader(let items): return .header(cells: items.compactMap { $0.tableCell })
        default: return nil
        }
    }
}
