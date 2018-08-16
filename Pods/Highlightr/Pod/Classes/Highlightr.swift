//
//  Highlightr.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/10/16.
//
//

import Foundation
import JavaScriptCore

#if os(OSX)
    import AppKit
#endif

/// Utility class for generating a highlighted NSAttributedString from a String.
open class Highlightr
{
    /// Returns the current Theme.
    open var theme : Theme!
    {
        didSet
        {
            themeChanged?(theme)
        }
    }
    
    /// This block will be called every time the theme changes.
    open var themeChanged : ((Theme) -> Void)?

    /// Defaults to `false` - when `true`, forces highlighting to finish even if illegal syntax is detected.
    open var ignoreIllegals = false

    private let hljs: JSValue

    private let bundle : Bundle
    private let htmlStart = "<"
    private let spanStart = "span class=\""
    private let spanStartClose = "\">"
    private let spanEnd = "/span>"
    private let htmlEscape = try! NSRegularExpression(pattern: "&#?[a-zA-Z0-9]+?;", options: .caseInsensitive)
    
    /**
     Default init method.

     - parameter highlightPath: The path to `highlight.min.js`. Defaults to `Highlightr.framework/highlight.min.js`

     - returns: Highlightr instance.
     */
    public init?(highlightPath: String? = nil)
    {
        let jsContext = JSContext()!
        let window = JSValue(newObjectIn: jsContext)
        jsContext.setObject(window, forKeyedSubscript: "window" as NSString)

        let bundle = Bundle(for: Highlightr.self)
        self.bundle = bundle
        guard let hgPath = highlightPath ?? bundle.path(forResource: "highlight.min", ofType: "js") else
        {
            return nil
        }
        
        let hgJs = try! String.init(contentsOfFile: hgPath)
        let value = jsContext.evaluateScript(hgJs)
        if value?.toBool() != true
        {
            return nil
        }
        guard let hljs = window?.objectForKeyedSubscript("hljs") else
        {
            return nil
        }
        self.hljs = hljs
        
        guard setTheme(to: "pojoaque") else
        {
            return nil
        }
        
    }
    
    /**
     Set the theme to use for highlighting.
     
     - parameter to: Theme name
     
     - returns: true if it was possible to set the given theme, false otherwise
     */
    @discardableResult
    open func setTheme(to name: String) -> Bool
    {
        guard let defTheme = bundle.path(forResource: name+".min", ofType: "css") else
        {
            return false
        }
        let themeString = try! String.init(contentsOfFile: defTheme)
        theme =  Theme(themeString: themeString)

        
        return true
    }
    
    /**
     Takes a String and returns a NSAttributedString with the given language highlighted.
     
     - parameter code:           Code to highlight.
     - parameter languageName:   Language name or alias. Set to `nil` to use auto detection.
     - parameter fastRender:     Defaults to true - When *true* will use the custom made html parser rather than Apple's solution.
     
     - returns: NSAttributedString with the detected code highlighted.
     */
    open func highlight(_ code: String, as languageName: String? = nil, fastRender: Bool = true) -> NSAttributedString?
    {
        let ret: JSValue
        if let languageName = languageName
        {
            ret = hljs.invokeMethod("highlight", withArguments: [languageName, code, ignoreIllegals])
        }else
        {
            // language auto detection
            ret = hljs.invokeMethod("highlightAuto", withArguments: [code])
        }

        let res = ret.objectForKeyedSubscript("value")
        guard var string = res!.toString() else
        {
            return nil
        }
        
        var returnString : NSAttributedString?
        if(fastRender)
        {
            returnString = processHTMLString(string)!
        }else
        {
            string = "<style>"+theme.lightTheme+"</style><pre><code class=\"hljs\">"+string+"</code></pre>"
            let opt: [NSAttributedString.DocumentReadingOptionKey : Any] = [
             .documentType: NSAttributedString.DocumentType.html,
             .characterEncoding: String.Encoding.utf8.rawValue
             ]
            
            let data = string.data(using: String.Encoding.utf8)!
            safeMainSync
            {
                returnString = try? NSMutableAttributedString(data:data, options: opt, documentAttributes:nil)
            }
        }
        
        return returnString
    }
    
    /**
     Returns a list of all the available themes.
     
     - returns: Array of Strings
     */
    open func availableThemes() -> [String]
    {
        let paths = bundle.paths(forResourcesOfType: "css", inDirectory: nil) as [NSString]
        var result = [String]()
        for path in paths {
            result.append(path.lastPathComponent.replacingOccurrences(of: ".min.css", with: ""))
        }
        
        return result
    }
    
    /**
     Returns a list of all supported languages.
     
     - returns: Array of Strings
     */
    open func supportedLanguages() -> [String]
    {
        let res = hljs.invokeMethod("listLanguages", withArguments: [])
        return res!.toArray() as! [String]
    }
    
    /**
     Execute the provided block in the main thread synchronously.
     */
    private func safeMainSync(_ block: @escaping ()->())
    {
        if Thread.isMainThread
        {
            block()
        }else
        {
            DispatchQueue.main.sync { block() }
        }
    }
    
    private func processHTMLString(_ string: String) -> NSAttributedString?
    {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil
        var scannedString: NSString?
        let resultString = NSMutableAttributedString(string: "")
        var propStack = ["hljs"]
        
        while !scanner.isAtEnd
        {
            var ended = false
            if scanner.scanUpTo(htmlStart, into: &scannedString)
            {
                if scanner.isAtEnd
                {
                    ended = true
                }
            }
            
            if scannedString != nil && scannedString!.length > 0 {
                let attrScannedString = theme.applyStyleToString(scannedString! as String, styleList: propStack)
                resultString.append(attrScannedString)
                if ended
                {
                    continue
                }
            }
            
            scanner.scanLocation += 1
            
            let string = scanner.string as NSString
            let nextChar = string.substring(with: NSMakeRange(scanner.scanLocation, 1))
            if(nextChar == "s")
            {
                scanner.scanLocation += (spanStart as NSString).length
                scanner.scanUpTo(spanStartClose, into:&scannedString)
                scanner.scanLocation += (spanStartClose as NSString).length
                propStack.append(scannedString! as String)
            }
            else if(nextChar == "/")
            {
                scanner.scanLocation += (spanEnd as NSString).length
                propStack.removeLast()
            }else
            {
                let attrScannedString = theme.applyStyleToString("<", styleList: propStack)
                resultString.append(attrScannedString)
                scanner.scanLocation += 1
            }
            
            scannedString = nil
        }
        
        let results = htmlEscape.matches(in: resultString.string,
                                               options: [.reportCompletion],
                                               range: NSMakeRange(0, resultString.length))
        var locOffset = 0
        for result in results
        {
            let fixedRange = NSMakeRange(result.range.location-locOffset, result.range.length)
            let entity = (resultString.string as NSString).substring(with: fixedRange)
            if let decodedEntity = HTMLUtils.decode(entity)
            {
                resultString.replaceCharacters(in: fixedRange, with: String(decodedEntity))
                locOffset += result.range.length-1;
            }
            

        }

        return resultString
    }
    
}
