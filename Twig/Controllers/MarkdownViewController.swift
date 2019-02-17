//
//  MarkdownViewController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import cmark_gfm_swift

class MarkdownViewController: NSViewController, NSTextViewDelegate {

  @IBOutlet var markdownTextView: NSTextView!

  private var debouncedGeneratePreview: Debouncer!

  /// The split view controller holding this markdown view controller
  private var splitViewController: NSSplitViewController? {
    return parent as? NSSplitViewController
  }

  /// The preview view controller for this markdown view controller
  private var previewViewController: PreviewViewController? {
    return splitViewController?.splitViewItems.last?.viewController as? PreviewViewController
  }

  /// Cocoa binding for text inside markdownTextView
  @objc var attributedMarkdownTextInput: NSAttributedString {
    get {
      return NSAttributedString(string: markdownTextView.string)
    }
    set {
      syntaxHighlight()
      debouncedGeneratePreview.call()
      setWordCount()
    }
  }

  override var acceptsFirstResponder: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup notification observer for preferences change
    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(reloadUI))
    // Setup notification observer for system dark/light mode change
    NotificationCenter.receive(.appearanceChanged, instance: self, selector: #selector(generatePreview))

    // Setup a 200ms debouncer for generating the markdown preview
    debouncedGeneratePreview = Debouncer(delay: 0.2) {
      self.generatePreview()
    }

    if let preview = splitViewController?.splitViewItems.last {
      preview.isCollapsed = !preferences.showPreviewOnStartup
    }

    markdownTextView.delegate = self
    markdownTextView.font = preferences.font
    markdownTextView.insertionPointColor = .gray
    markdownTextView.textContainerInset = NSSize(width: 10.0, height: 10.0)
  }

  override func viewDidAppear() {
    reloadUI()
  }

  // MARK: - First responder methods for exporting from WKWebView

  @IBAction func exportPDF(sender: NSMenuItem) {
    if let pvc = previewViewController {
      PDFExporter.export(from: pvc.webPreview)
    }
  }

  @IBAction func exportHTML(sender: NSMenuItem) {
    if let pvc = previewViewController {
      HTMLExporter.export(from: pvc.webPreview)
    }
  }

  @IBAction func exportLatex(sender: NSMenuItem) {
    LatexExporter.export(from: markdownTextView)
  }

  @IBAction func exportXML(sender: NSMenuItem) {
    XMLExporter.export(from: markdownTextView)
  }

  // MARK: - First responder methods for various markdown formatting shortcuts

  @IBAction func bold(sender: NSMenuItem) {
    markdownTextView.replace(left: "**", right: "**")
    reloadUI()
  }

  @IBAction func italic(sender: NSMenuItem) {
    markdownTextView.replace(left: "_", right: "_")
    reloadUI()
  }

  @IBAction func strikethrough(sender: NSMenuItem) {
    markdownTextView.replace(left: "~~", right: "~~")
    reloadUI()
  }

  @IBAction func code(sender: NSMenuItem) {
    markdownTextView.replace(left: "`", right: "`")
    reloadUI()
  }

  @IBAction func codeBlock(sender: NSMenuItem) {
    markdownTextView.replace(left: "```\n", right: "\n```", newLineIfSelected: true)
    reloadUI()
  }

  @IBAction func h1(sender: NSMenuItem) {
    markdownTextView.replace(left: "# ", atLineStart: true)
    reloadUI()
  }

  @IBAction func h2(sender: NSMenuItem) {
    markdownTextView.replace(left: "## ", atLineStart: true)
    reloadUI()
  }

  @IBAction func h3(sender: NSMenuItem) {
    markdownTextView.replace(left: "### ", atLineStart: true)
    reloadUI()
  }

  @IBAction func h4(sender: NSMenuItem) {
    markdownTextView.replace(left: "#### ", atLineStart: true)
    reloadUI()
  }

  @IBAction func h5(sender: NSMenuItem) {
    markdownTextView.replace(left: "##### ", atLineStart: true)
    reloadUI()
  }

  @IBAction func h6(sender: NSMenuItem) {
    markdownTextView.replace(left: "###### ", atLineStart: true)
    reloadUI()
  }

  @IBAction func math(sender: NSMenuItem) {
    markdownTextView.replace(left: "$", right: "$")
    reloadUI()
  }

  @IBAction func mathBlock(sender: NSMenuItem) {
    markdownTextView.replace(left: "$$\n", right: "\n$$", newLineIfSelected: true)
    reloadUI()
  }

  // MARK: - Functions handling markdown editing

  /// Syntax highlight the markdownTextView contents
  private func syntaxHighlight() {
    let markdownText = markdownTextView.string

    DispatchQueue.global(qos: .userInitiated).async {
      let highlightedCode = theme.highlightr.highlight(markdownText, as: "markdown")

      if let syntaxHighlighted = highlightedCode {
        let code = NSMutableAttributedString(attributedString: syntaxHighlighted)
        code.withFont(preferences.font)

        DispatchQueue.main.async {
          let cursorPosition = self.markdownTextView.selectedRanges[0].rangeValue.location
          self.markdownTextView.textStorage?.beginEditing()
          self.markdownTextView.textStorage?.setAttributedString(code)
          self.markdownTextView.textStorage?.endEditing()
          self.markdownTextView.setSelectedRange(NSRange(location: cursorPosition, length: 0))
        }
      }
    }
  }

  /// Parse the markdownTextView contents into HTML and load it into the webview
  @objc private func generatePreview() {
    // If preview is collapsed, return
    guard
      let preview = splitViewController?.splitViewItems.last,
      !preview.isCollapsed
    else { return }

    // Don't escape a double backslash
    let markdownText = markdownTextView.string.replacingOccurrences(of: "\\", with: "\\\\")

    DispatchQueue.global(qos: .userInitiated).async {
      if let parsed = Node(markdown: markdownText)?.html {
        DispatchQueue.main.async {
          self.previewViewController?.captureScroll {
            self.previewViewController?.webPreview.loadHTMLString(html.getHTML(with: parsed), baseURL: nil)
          }
        }
      }
    }
  }

  // MARK: - Private functions for updating and setting view components

  /// Update any UI related components
  @objc private func reloadUI() {
    syntaxHighlight()
    view.updateLayer()
    self.generatePreview()
    self.markdownTextView.isContinuousSpellCheckingEnabled = preferences.spellcheckEnabled
  }

  /// Sets the word count in the titlebar word count accessory
  private func setWordCount() {
    let wordCountView = view.window?.titlebarAccessoryViewControllers.first?.view.subviews.first as? NSTextField
    guard let wordCount = markdownTextView.textStorage?.words.count else { return }

    var countString = String(describing: wordCount) + " word"

    if wordCount > 1 {
      countString += "s"
    } else if wordCount < 1 {
      countString = ""
    }
    wordCountView?.stringValue = countString
  }

}
