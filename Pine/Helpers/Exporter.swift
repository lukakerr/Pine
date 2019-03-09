//
//  Exporter.swift
//  Pine
//
//  Created by Luka Kerr on 16/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import WebKit
import cmark_gfm_swift

/// A protocol that various exporters can conform to
/// Must provide a filetype and generic method used to export
protocol Exportable {

  /// The type of file being exported
  static var filetype: String { get }

  /// Export data from a view
  ///
  /// - Parameters:
  ///   - view: the instance of the view
  static func export<T>(from view: T)

}

struct PDFExporter: Exportable {
  static var filetype = "pdf"

  static func export<T>(from view: T) {
    // We expect the view to be a webview from which we can HTML and print from
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

struct HTMLExporter: Exportable {
  static var filetype = "html"

  static func export<T>(from view: T) {
    // We expect the view to be a webview from which we can get HTML
    let webview = view as! WKWebView

    webview.evaluateJavaScript("document.documentElement.outerHTML") { (response, err) in
      if let HTMLString = response as? String {
        let HTMLData = "<!DOCTYPE HTML>" + HTMLString
        if let data = HTMLData.data(using: .utf8) {
          let fileSaver = FileSaver(data: data, filetype: filetype)
          do {
            try fileSaver.save()
          } catch let error as SaveError {
            Alert.error(message: error.description)
          } catch {}
        }
      }
    }
  }

}

struct LatexExporter: Exportable {
  static var filetype = "tex"

  static func export<T>(from view: T) {
    // We expect the view to be a text view
    let markdownTextView = view as! NSTextView

    if let l = Node(
      markdown: markdownTextView.string,
      options: preferences.markdownOptions,
      extensions: preferences.markdownExtensions
    )?.latex {
      let latex = """
      \\documentclass[12pt]{article}
      \\begin{document}
      \(l)
      \\end{document}
      """

      if let data = latex.data(using: .utf8) {
        let fileSaver = FileSaver(data: data, filetype: filetype)
        do {
          try fileSaver.save()
        } catch let error as SaveError {
          Alert.error(message: error.description)
        } catch {}
      }
    }
  }
}

struct XMLExporter: Exportable {
  static var filetype = "xml"

  static func export<T>(from view: T) {
    // We expect the view to be a text view
    let markdownTextView = view as! NSTextView

    guard
      let xml = Node(
        markdown: markdownTextView.string,
        options: preferences.markdownOptions,
        extensions: preferences.markdownExtensions
      )?.xml,
      let data = xml.data(using: .utf8)
    else { return }

    let fileSaver = FileSaver(data: data, filetype: filetype)
    do {
      try fileSaver.save()
    } catch let error as SaveError {
      Alert.error(message: error.description)
    } catch {}
  }
}

struct TXTExporter: Exportable {
  static var filetype = "txt"

  static func export<T>(from view: T) {
    // We expect the view to be a text view
    let markdownTextView = view as! NSTextView

    let txt = markdownTextView.string

    guard let data = txt.data(using: .utf8) else { return }

    let fileSaver = FileSaver(data: data, filetype: filetype)
    do {
      try fileSaver.save()
    } catch let error as SaveError {
      Alert.error(message: error.description)
    } catch {}
  }
}
