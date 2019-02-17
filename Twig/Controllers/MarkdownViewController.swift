//
//  MarkdownViewController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Highlightr
import cmark_gfm_swift

let MARKDOWN_SYNTAX = "Markdown"

class MarkdownViewController: NSViewController, NSTextViewDelegate, HighlightDelegate {

  private var scrollView: NSScrollView!
  private var markdownTextView: NSTextView!
  private var layoutManager: NSLayoutManager!

  public var textStorage: CodeAttributedString!

  private var debouncedGeneratePreview: Debouncer!

  /// The split view controller holding this markdown view controller
  private var splitViewController: NSSplitViewController? {
    return parent as? NSSplitViewController
  }

  /// The preview view controller for this markdown view controller
  private var previewViewController: PreviewViewController? {
    return splitViewController?.splitViewItems.last?.viewController as? PreviewViewController
  }

  /// The word count text field instance
  private var wordCountTextField: NSTextField? {
    return view.window?.titlebarAccessoryViewControllers.first?.view.subviews.first as? NSTextField
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

    self.setupTextStorage()
    self.setupScrollView()
    self.setupLayoutManager()
    self.setupMarkdownTextView()

    if let textContainer = markdownTextView.textContainer {
      layoutManager.addTextContainer(textContainer)
    }

    scrollView.documentView = markdownTextView

    view.addSubview(scrollView)
  }

  // MARK: - Private functions for updating and setting view components

  func setupTextStorage() {
    textStorage = CodeAttributedString(highlightr: theme.highlightr)
    textStorage.highlightDelegate = self
    textStorage.language = MARKDOWN_SYNTAX
  }

  func setupScrollView() {
    scrollView = NSScrollView()
    scrollView.frame = view.frame
    scrollView.borderType = .noBorder
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autoresizingMask = [.width, .height]
  }

  func setupLayoutManager() {
    layoutManager = NSLayoutManager()
    textStorage.addLayoutManager(layoutManager)
  }

  func setupMarkdownTextView() {
    markdownTextView = NSTextView()
    markdownTextView.delegate = self
    markdownTextView.allowsUndo = true
    markdownTextView.isEditable = true
    markdownTextView.usesFindBar = true
    markdownTextView.isRichText = false
    markdownTextView.isSelectable = true
    markdownTextView.frame = view.bounds
    markdownTextView.font = preferences.font
    markdownTextView.drawsBackground = false
    markdownTextView.frame = scrollView.bounds
    markdownTextView.autoresizingMask = [.width]
    markdownTextView.insertionPointColor = .gray
    markdownTextView.isVerticallyResizable = true
    markdownTextView.isHorizontallyResizable = false
    markdownTextView.textContainerInset = NSSize(width: 10.0, height: 10.0)
  }

  /// Update any UI related components
  @objc private func reloadUI() {
    syntaxHighlight()
    view.updateLayer()
    generatePreview()
    markdownTextView.isContinuousSpellCheckingEnabled = preferences.spellcheckEnabled
  }

  /// Sets the word count in the titlebar word count accessory
  private func setWordCount() {
    guard let count = markdownTextView.textStorage?.words.count else { return }

    var countString = "\(count) word"

    if count > 1 {
      countString += "s"
    } else if count < 1 {
      countString = ""
    }

    wordCountTextField?.stringValue = countString
  }

  // MARK: - Functions handling markdown editing

  /// Called when the syntax highlighter finishes
  func didHighlight(_ range: NSRange, success: Bool) {
    setWordCount()
    debouncedGeneratePreview.call()
  }

  /// Syntax highlight the entire markdownTextView contents
  private func syntaxHighlight() {
    let markdownText = markdownTextView.string

    DispatchQueue.global(qos: .userInitiated).async {
      theme.setFont(to: preferences.font)

      guard
        let highlightedCode = self.textStorage.highlightr.highlight(markdownText, as: MARKDOWN_SYNTAX)
      else { return }

      DispatchQueue.main.async {
        let cursorPosition = self.markdownTextView.selectedRanges[0].rangeValue
        self.textStorage.beginEditing()
        self.textStorage.setAttributedString(highlightedCode)
        self.textStorage.endEditing()
        self.markdownTextView.setSelectedRange(cursorPosition)
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

}

extension MarkdownViewController {

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

}

extension MarkdownViewController {

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

}
