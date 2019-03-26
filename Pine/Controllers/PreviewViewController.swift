//
//  PreviewViewController.swift
//  Pine
//
//  Created by Luka Kerr on 26/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import WebKit

class PreviewViewController: NSViewController, WKNavigationDelegate {

  @IBOutlet weak private var webPreview: WKWebView!

  /// The current directory that external assets can load from
  private var permissionDirectory: URL?

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

  public func scrollTo(percentage: Float) {
    let jsString = """
      var height = document.body.clientHeight - window.innerHeight + 30;

      window.scrollTo(0, height * \(percentage));
    """

    webPreview.evaluateJavaScript(jsString) { (_, _) in }
  }

  /// Set the content of the preview to a HTML string
  public func setContent(with html: String) {
    self.webPreview.loadHTMLString(html, baseURL: self.permissionDirectory ?? nil)
  }

  /// Set the permissions of the preview for a given file
  public func setPermissions(for url: URL) {
    let base = url.deletingLastPathComponent().standardizedFileURL

    // If same permissions directory return early,
    // we don't want to load another request if we don't have to
    if base == self.permissionDirectory {
      return
    }

    // Set permissions directory
    self.permissionDirectory = base

    self.webPreview.load(URLRequest(url: url))
  }

  // Handle when a link is clicked
  public func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard let url = navigationAction.request.url else { return }

    let urlString = url.absoluteString

    if urlString.isWebLink {
      decisionHandler(.cancel)
      NSWorkspace.shared.open(url)
    } else if urlString.isMarkdown {
      decisionHandler(.cancel)
      (DocumentController.shared as? DocumentController)?.openMarkdownFile(withContentsOf: url)
    } else {
      decisionHandler(.allow)
    }
  }

}
