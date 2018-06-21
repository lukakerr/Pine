//
//  Exporter.swift
//  Twig
//
//  Created by Luka Kerr on 16/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import WebKit

public class Exporter {
  
  /// Export PDF data from a webview
  ///
  /// - Parameters:
  ///   - webview: the instance of the webview
  static func exportPDF(from webview: WKWebView) {
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
  
  /// Export HTML data from a webview
  ///
  /// - Parameters:
  ///   - webview: the instance of the webview
  static func exportHTML(from webview: WKWebView) {
    webview.evaluateJavaScript("document.documentElement.outerHTML") { (response, err) in
      if let HTMLString = response as? String {
        let HTMLData = "<!DOCTYPE HTML>" + HTMLString
        if let data = HTMLData.data(using: .utf8) {
          save(data, filetypes: ["html"], type: "HTML")
        }
      }
    }
  }
  
  /// Save data to a user chosen location
  ///
  /// - Parameters:
  ///   - data: the raw data to save
  ///   - filetypes: allowed filetypes to save the data as
  ///   - type: the type of file, used only in the popup title
  private static func save(_ data: Data, filetypes: [String], type: String) {
    let dialog = NSSavePanel()

    dialog.title = "Export as \(type)"
    dialog.allowedFileTypes = filetypes
    dialog.canCreateDirectories = true

    if (dialog.runModal() == .OK) {
      if let result = dialog.url {
        do {
          try data.write(to: result, options: .atomic)
        } catch {
          print("error:", error)
        }
      }
    }
  }

}
