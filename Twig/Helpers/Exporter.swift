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
    let PDFData = webview.dataWithPDF(inside: webview.frame)
    save(PDFData, filetypes: ["pdf"], type: "PDF")
  }
  
  /// Export HTML data from a webview
  ///
  /// - Parameters:
  ///   - webview: the instance of the webview
  static func exportHTML(from webview: WKWebView) {
    webview.evaluateJavaScript("document.documentElement.outerHTML") { (response, err) in
      let HTMLString = "<!DOCTYPE HTML>" + String(describing: response)
      if let HTMLData = HTMLString.data(using: .utf8) {
        save(HTMLData, filetypes: ["html"], type: "HTML")
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
