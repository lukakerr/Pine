//
//  ReferenceViewController.swift
//  Pine
//
//  Created by Luka Kerr on 22/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa
import WebKit

class ReferenceViewController: NSViewController {

  @IBOutlet weak var webView: WKWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    webView.setValue(false, forKey: "drawsBackground")

    NotificationCenter.receive(
      .preferencesChanged,
      instance: self,
      selector: #selector(loadReference)
    )

    self.loadReference()
  }

  @objc func loadReference() {
    guard
      let reference = Bundle.main.url(forResource: "Reference", withExtension: "html"),
      let referenceContents = try? String(contentsOf: reference, encoding: .utf8)
    else { return }

    let contents = html.getHTML(with: referenceContents)

    self.webView.loadHTMLString(contents, baseURL: nil)
  }

}
