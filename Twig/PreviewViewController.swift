//
//  PreviewViewController.swift
//  Twig
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Down
import WebKit

class PreviewViewController: NSViewController, WKNavigationDelegate {

  @IBOutlet weak var webPreview: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webPreview.navigationDelegate = self
  }
  
  // Open web links in browser, not webview
  public func webView(_ webView: WKWebView,
                      decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    let url = navigationAction.request.url

    if String(describing: url).contains("http") {
      decisionHandler(.cancel)
      if let url = url {
        NSWorkspace.shared.open(url)
      }
    } else {
      decisionHandler(.allow)
    }
  }
  
}
