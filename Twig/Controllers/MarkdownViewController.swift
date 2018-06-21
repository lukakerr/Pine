//
//  ViewController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Highlightr
import Down

class MarkdownViewController: NSViewController, NSTextViewDelegate {

  @IBOutlet var markdownTextView: NSTextView!
  @IBOutlet weak var transparentView: NSVisualEffectView!

  private var debouncedGeneratePreview: Debouncer!
  private let highlightr = Highlightr()!
  
  // Cocoa binding for text inside markdownTextView
  @objc var attributedMarkdownTextInput: NSAttributedString {
    get {
      return NSAttributedString(string: markdownTextView.string)
    }
    set {
      syntaxHighlight(newValue.string)
      debouncedGeneratePreview.call()
      setWordCount()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup notification observer for theme change
    NotificationCenter.receive("preferencesChanged", instance: self, selector: #selector(self.reloadUI))
    // Setup notification observer for system dark/light mode change
    NotificationCenter.receive("appearanceChanged", instance: self, selector: #selector(self.reGeneratePreview))
    
    debouncedGeneratePreview = Debouncer(delay: 0.2) {
      self.generatePreview(self.markdownTextView.string)
    }
    
    if let preview = getSplitViewController()?.splitViewItems.last {
      preview.isCollapsed = !preferences.showPreviewOnStartup
    }
    
    markdownTextView.delegate = self
    markdownTextView.font = preferences.font
    markdownTextView.insertionPointColor = .gray
    markdownTextView.textContainerInset = NSSize(width: 10.0, height: 10.0)
  }
  
  override func viewDidAppear() {
    highlightr.setTheme(to: theme.syntax)
    theme.background = highlightr.theme.themeBackgroundColor
    reloadUI()
  }
  
  override var acceptsFirstResponder: Bool {
    return true
  }
  
  @IBAction func togglePreview(sender: NSMenuItem) {
    if let preview = getSplitViewController()?.splitViewItems.last {
      preview.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
      preview.animator().isCollapsed = !preview.isCollapsed
    }
  }
  
  @IBAction func exportPDF(sender: NSMenuItem) {
    if let pvc = getPreviewViewController() {
      Exporter.exportPDF(from: pvc.webPreview)
    }
  }
  
  @IBAction func exportHTML(sender: NSMenuItem) {
    if let pvc = getPreviewViewController() {
      Exporter.exportHTML(from: pvc.webPreview)
    }
  }
  
  // Syntax highlight the given markdown string and insert into text view
  private func syntaxHighlight(_ string: String) {
    highlightr.setTheme(to: theme.syntax)
    theme.background = highlightr.theme.themeBackgroundColor
    
    DispatchQueue.global(qos: .userInitiated).async {
      let highlightedCode = self.highlightr.highlight(string, as: "markdown")
      
      if let syntaxHighlighted = highlightedCode {
        let code = NSMutableAttributedString(attributedString: syntaxHighlighted)
        code.withFont(preferences.font)

        DispatchQueue.main.async {
          let cursorPosition = self.markdownTextView.selectedRanges[0].rangeValue.location
          self.markdownTextView.textStorage?.beginEditing()
          self.markdownTextView.textStorage?.setAttributedString(code)
          self.markdownTextView.textStorage?.endEditing()
          self.markdownTextView.setSelectedRange(NSMakeRange(cursorPosition, 0))
        }
      }
    }
  }
  
  private func generatePreview(_ string: String) {
    if let svc = self.getSplitViewController(),
      let preview = svc.splitViewItems.last {
      let previewViewController = preview.viewController as? PreviewViewController
      
      if preview.isCollapsed { return }
        
      DispatchQueue.global(qos: .userInitiated).async {
        if let parsed = try? Down(markdownString: string).toHTML() {
          DispatchQueue.main.async {
            previewViewController?.captureScroll() {
              previewViewController?.webPreview.loadHTMLString(html.getHTML(with: parsed), baseURL: nil)
            }
          }
        }
      }
    }
  }

  @objc private func reloadUI() {
    syntaxHighlight(markdownTextView.string)
    self.view.updateLayer()
    reGeneratePreview()
  }
  
  @objc private func reGeneratePreview() {
    generatePreview(markdownTextView.string)
  }
  
  private func setWordCount() {
    let wordCountView = self.view.window?.titlebarAccessoryViewControllers.first?.view.subviews.first as? NSTextField
    guard let wordCount = self.markdownTextView.textStorage?.words.count else { return }
    
    var countString = String(describing: wordCount) + " word"
    
    if wordCount > 1 {
      countString += "s"
    } else if wordCount < 1 {
      countString = ""
    }
    wordCountView?.stringValue = countString
  }

}
