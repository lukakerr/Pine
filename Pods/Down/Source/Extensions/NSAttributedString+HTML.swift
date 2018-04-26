//
//  NSAttributedString+HTML.swift
//  Down
//
//  Created by Rob Phillips on 6/1/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif


extension NSAttributedString {

    /**
     Instantiates an attributed string with the given HTML string

     - parameter htmlString: An HTML string

     - throws: `HTMLDataConversionError` or an instantiation error

     - returns: An attributed string
     */
    convenience init(htmlString: String) throws {
        guard let data = htmlString.data(using: String.Encoding.utf8) else {
            throw DownErrors.htmlDataConversionError
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
        ]
        try self.init(data: data, options: options, documentAttributes: nil)
    }

}
