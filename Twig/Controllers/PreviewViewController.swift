//
//  PreviewViewController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import WebKit

class PreviewViewController: NSViewController, WKNavigationDelegate {

  @IBOutlet weak var webPreview: WKWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    webPreview.navigationDelegate = self
    webPreview.setValue(false, forKey: "drawsBackground")

    #if DEBUG
      // When developing we want to be able to inspect element in the preview
      webPreview.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    #endif
  }

  /// A closure that returns the y scoll position of the webview
  public func captureScroll(completion: @escaping () -> Void) {
    webPreview.evaluateJavaScript("window.scrollY;") { (response, err) in
      if let pos = response as? Int {
        html.y = pos
        completion()
      }
    }
  }

  // Open web links in browser, not webview
  public func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard let url = navigationAction.request.url else { return }

    if url.absoluteString.isWebLink {
      decisionHandler(.cancel)
      NSWorkspace.shared.open(url)
    } else {
      decisionHandler(.allow)
    }
  }

}
