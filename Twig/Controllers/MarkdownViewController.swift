//
//  MarkdownViewController.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Highlightr

class MarkdownViewController: NSViewController, NSTextViewDelegate {

  @IBOutlet var markdownTextView: NSTextView!

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

  override var acceptsFirstResponder: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup notification observer for preferences change
    NotificationCenter.receive(.preferencesChanged, instance: self, selector: #selector(reloadUI))
    // Setup notification observer for system dark/light mode change
    NotificationCenter.receive(.appearanceChanged, instance: self, selector: #selector(reGeneratePreview))

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

  // MARK: - First responder methods for exporting from WKWebView

  @IBAction func exportPDF(sender: NSMenuItem) {
    if let pvc = getPreviewViewController() {
      PDFExporter.export(from: pvc.webPreview)
    }
  }

  @IBAction func exportHTML(sender: NSMenuItem) {
    if let pvc = getPreviewViewController() {
      HTMLExporter.export(from: pvc.webPreview)
    }
  }

  // MARK: - Functions handling syntax highlighting and preview generation

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
          self.markdownTextView.setSelectedRange(NSRange(location: cursorPosition, length: 0))
        }
      }
    }
  }

  private func generatePreview(_ string: String) {
    if let svc = getSplitViewController(),
      let preview = svc.splitViewItems.last {
      let previewViewController = preview.viewController as? PreviewViewController

      if preview.isCollapsed { return }

      DispatchQueue.global(qos: .userInitiated).async {
        if let parsed = Node(markdown: string)?.html {
          DispatchQueue.main.async {
            previewViewController?.captureScroll {
              previewViewController?.webPreview.loadHTMLString(html.getHTML(with: parsed), baseURL: nil)
            }
          }
        }
      }
    }
  }

  // MARK: - Markdown formatting shortcuts

  @IBAction func bold(sender: NSMenuItem) {
    replace(left: "**", right: "**")
  }

  @IBAction func italic(sender: NSMenuItem) {
    replace(left: "_", right: "_")
  }

  @IBAction func strikethrough(sender: NSMenuItem) {
    replace(left: "~~", right: "~~")
  }

  @IBAction func code(sender: NSMenuItem) {
    replace(left: "`", right: "`")
  }

  @IBAction func codeBlock(sender: NSMenuItem) {
    replace(left: "```\n", right: "\n```", newLineIfSelected: true)
  }

  @IBAction func h1(sender: NSMenuItem) {
    replace(left: "# ", atLineStart: true)
  }

  @IBAction func h2(sender: NSMenuItem) {
    replace(left: "## ", atLineStart: true)
  }

  @IBAction func h3(sender: NSMenuItem) {
    replace(left: "### ", atLineStart: true)
  }

  @IBAction func h4(sender: NSMenuItem) {
    replace(left: "#### ", atLineStart: true)
  }

  @IBAction func h5(sender: NSMenuItem) {
    replace(left: "##### ", atLineStart: true)
  }

  @IBAction func math(sender: NSMenuItem) {
    replace(left: "$", right: "$")
  }

  @IBAction func mathBlock(sender: NSMenuItem) {
    replace(left: "$$\n", right: "\n$$", newLineIfSelected: true)
  }

  /// Inserts the given left and right characters on either side of selected text,
  /// or creates a new string and inserts the cursor in the middle of it
  ///
  /// - Parameters:
  ///   - left: the left characters
  ///   - right: the right (optional) characters
  ///   - atLineStart: whether the left character should be inserted at the start of the line
  ///   - newLineIfSelected: whether to create a newline on the left and right if the text is selected
  private func replace(
    left: String,
    right: String? = nil,
    atLineStart: Bool = false,
    newLineIfSelected: Bool = false
  ) {
    let range = markdownTextView.selectedRange()

    var leftText = left
    var rightText = right ?? ""

    if newLineIfSelected {
      leftText = "\n\(leftText)"
      rightText = "\(rightText)\n"
    }

    let text = (markdownTextView.string as NSString).substring(with: range)

    let replacement = "\(leftText)\(text)\(rightText)"
    let cursorPosition = markdownTextView.selectedRanges[0].rangeValue.location

    let newCursorPosition = cursorPosition + leftText.lengthOfBytes(using: .utf8)

    // Let NSTextView know we are going to make a replacement
    // This retains document history allowing for undo etc
    markdownTextView.shouldChangeText(in: range, replacementString: replacement)

    // Make replacement in range (length of 0 if nothing selected)
    markdownTextView.replaceCharacters(in: range, with: replacement)

    // Set cursor position to appropriate position if not replacing a selection
    // If replacing a selection, the cursor goes to the end of the replaced text
    if range.length == 0 {
      markdownTextView.setSelectedRange(NSRange(location: newCursorPosition, length: 0))
    }

    reloadUI()
  }

  // MARK: - Private functions for updating and setting view components

  @objc private func reloadUI() {
    syntaxHighlight(markdownTextView.string)
    view.updateLayer()
    reGeneratePreview()
  }

  @objc private func reGeneratePreview() {
    generatePreview(markdownTextView.string)
  }

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

extension MarkdownViewController {

  public func getSplitViewController() -> NSSplitViewController? {
    return parent as? NSSplitViewController
  }

  public func getPreviewViewController() -> PreviewViewController? {
    return getSplitViewController()?.splitViewItems.last?.viewController as? PreviewViewController
  }

}
