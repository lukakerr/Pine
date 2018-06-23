//
//  Exporter.swift
//  Twig
//
//  Created by Luka Kerr on 16/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import WebKit

/// A protocol that various exporters can conform to
/// Must provide a filetype and generic method used to export
protocol Exporter {
  static var filetype: String { get }
  
  /// Export data from a view
  ///
  /// - Parameters:
  ///   - view: the instance of the view
  static func export<T>(from view: T)
}

struct PDFExporter: Exporter {
  static var filetype = "pdf"

  static func export<T>(from view: T) {
    // we expect the view to be a webview from which we can HTML and print from
    let webview = view as! WKWebView

    webview.evaluateJavaScript("document.documentElement.outerHTML") { (response, err) in
      if let HTMLString = response as? String {
        let HTMLData = "<!DOCTYPE HTML>" + HTMLString
        let wv = WebView()
        wv.mainFrame.loadHTMLString(HTMLData, baseURL: nil)
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
          let printOptions = [NSPrintInfo.AttributeKey.jobDisposition: NSPrintInfo.JobDisposition.save]
          let printInfo = NSPrintInfo(dictionary: printOptions)
          printInfo.topMargin = 40.0
          printInfo.leftMargin = 40.0
          printInfo.rightMargin = 40.0
          printInfo.bottomMargin = 40.0
          printInfo.isVerticallyCentered = false
          
          let printOp = NSPrintOperation(view: wv.mainFrame.frameView.documentView, printInfo: printInfo)
          printOp.showsPrintPanel = false
          printOp.showsProgressPanel = false
          printOp.pdfPanel = NSPDFPanel()
          printOp.pdfPanel.options = [.showsPaperSize, .showsOrientation]
          printOp.run()
        }
      }
    }
  }

}

struct HTMLExporter: Exporter {
  static var filetype = "html"
  
  static func export<T>(from view: T) {
    // we expect the view to be a webview from which we can get HTML
    let webview = view as! WKWebView

    webview.evaluateJavaScript("document.documentElement.outerHTML") { (response, err) in
      if let HTMLString = response as? String {
        let HTMLData = "<!DOCTYPE HTML>" + HTMLString
        if let data = HTMLData.data(using: .utf8) {
          let fileSaver = FileSaver(data: data, filetypes: [self.filetype])
          fileSaver.save()
        }
      }
    }
  }

}
