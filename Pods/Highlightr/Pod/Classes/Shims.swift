//
//  Shims.swift
//  Pods
//
//  Created by Kabir Oberai on 19/06/18.
//
//

import Foundation

#if os(OSX)
    import AppKit
#endif

#if swift(>=4.2)
    public typealias AttributedStringKey = NSAttributedString.Key
#else
    public typealias AttributedStringKey = NSAttributedStringKey
#endif

#if swift(>=4.2) && os(iOS)
    public typealias TextStorageEditActions = NSTextStorage.EditActions
#else
    public typealias TextStorageEditActions = NSTextStorageEditActions
#endif
