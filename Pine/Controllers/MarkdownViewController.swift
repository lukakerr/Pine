//
//  MarkdownViewController.swift
//  Pine
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import Highlightr
import cmark_gfm_swift

let MARKDOWN_SYNTAX = "Markdown"

class MarkdownViewController: NSViewController, NSTextViewDelegate, HighlightDelegate {

  public var markdownTextView: MarkdownTextView!
  public var textStorage: CodeAttributedString!

  private var scrollView: NSScrollView!
  private var layoutManager: MarkdownLayoutManager!
  private var debouncedGeneratePreview: Debouncer!

  /// The view's window controller
  private var windowController: PineWindowController? {
    return view.window?.windowController as? PineWindowController
  }

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

    // Setup notification observer for when scroll view scrolls
    NotificationCenter.receive(.boundsDidChange, instance: self, selector: #selector(scrollViewDidScroll))

    // Setup a 200ms debouncer for generating the markdown preview
    debouncedGeneratePreview = Debouncer(delay: 0.2) {
      self.generatePreview()
    }

    if let preview = splitViewController?.splitViewItems.last {
      preview.isCollapsed = !preferences[.showPreviewOnStartup]
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

  private func setupTextStorage() {
    textStorage = CodeAttributedString(highlightr: theme.highlightr)
    textStorage.highlightDelegate = self
    textStorage.language = MARKDOWN_SYNTAX
  }

  private func setupScrollView() {
    scrollView = NSScrollView()
    scrollView.frame = view.frame
    scrollView.borderType = .noBorder
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autoresizingMask = [.width, .height]
    scrollView.contentView.postsBoundsChangedNotifications = true
  }

  private func setupLayoutManager() {
    layoutManager = MarkdownLayoutManager()
    textStorage.addLayoutManager(layoutManager)
  }

  private func setupMarkdownTextView() {
    markdownTextView = MarkdownTextView()
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

    if #available(OSX 10.12.2, *) {
      markdownTextView.touchBar = self.makeTouchBar()
    }
  }

  /// Update any UI related components
  @objc private func reloadUI() {
    syntaxHighlight()
    view.updateLayer()
    generatePreview()
    layoutManager.fontDidUpdate()
    markdownTextView.setOverscroll()
  }

  /// When the scroll view scrolls, sync the preview if enabled in preferences
  @objc private func scrollViewDidScroll() {    
    guard
      preferences[.syncEditorAndPreview],
      let documentView = scrollView.documentView
    else { return }

    let visibleRect = documentView.visibleRect

    let yPos = visibleRect.origin.y
    let height = documentView.frame.size.height - visibleRect.height

    self.previewViewController?.scrollTo(percentage: Float(yPos / height))
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
    theme.setFont(to: preferences.font)

    let markdownText = markdownTextView.string

    DispatchQueue.global(qos: .userInitiated).async {
      guard
        let highlightedCode = self.textStorage.highlightr.highlight(markdownText, as: MARKDOWN_SYNTAX)
      else { return }

      DispatchQueue.main.async {
        let selectedRange = self.markdownTextView.selectedRange()
        self.textStorage.beginEditing()
        self.textStorage.setAttributedString(highlightedCode)
        self.textStorage.endEditing()
        self.markdownTextView.setSelectedRange(selectedRange)
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
      if let parsed = Node(
        markdown: markdownText,
        options: preferences.markdownOptions,
        extensions: preferences.markdownExtensions
      )?.html {
        DispatchQueue.main.async {
          self.previewViewController?.captureScroll {
            let doc = self.windowController?.document as? Document
            let fileURL = doc?.fileURL ?? URL(fileURLWithPath: "/")

            let styledHTML = html.getHTML(
              with: parsed,
              direction: self.markdownTextView.baseWritingDirection
            )

            self.previewViewController?.setPermissions(for: fileURL)
            self.previewViewController?.setContent(with: styledHTML)
          }
        }
      }
    }
  }

  /// Whenever typing attributes in the text view are changed, regenerate the preview
  func textView(
    _ textView: NSTextView,
    shouldChangeTypingAttributes oldTypingAttributes: [String: Any] = [:],
    toAttributes newTypingAttributes: [NSAttributedString.Key: Any] = [:]
  ) -> [NSAttributedString.Key: Any] {
    self.generatePreview()
    return newTypingAttributes
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

  @IBAction func image(sender: NSMenuItem) {
    markdownTextView.replace(left: "![", right: "]()")
    reloadUI()
  }

  @IBAction func HTMLImage(sender: NSMenuItem) {
    markdownTextView.replace(left: "<img src=\"", right: "\" width=\"\">")
    reloadUI()
  }

}

@available(OSX 10.12.2, *)
extension MarkdownViewController: NSTouchBarDelegate {

  override func makeTouchBar() -> NSTouchBar? {
    let touchBar = NSTouchBar()

    let identifiers: [NSTouchBarItem.Identifier] = [.h1, .h2, .h3, .bold, .italic, .code, .math, .image]

    touchBar.delegate = self
    touchBar.customizationIdentifier = .editorBar
    touchBar.defaultItemIdentifiers = identifiers
    touchBar.customizationAllowedItemIdentifiers = identifiers

    return touchBar
  }

  func touchBar(
    _ touchBar: NSTouchBar,
    makeItemForIdentifier identifier: NSTouchBarItem.Identifier
  ) -> NSTouchBarItem? {
    let item = NSCustomTouchBarItem(identifier: identifier)

    switch identifier {
    case .h1:
      item.view = NSButton(title: "H1", target: self, action: #selector(h1))
      item.customizationLabel = "Heading 1"
      return item

    case .h2:
      item.view = NSButton(title: "H2", target: self, action: #selector(h2))
      item.customizationLabel = "Heading 2"
      return item

    case .h3:
      item.view = NSButton(title: "H3", target: self, action: #selector(h3))
      item.customizationLabel = "Heading 3"
      return item

    case .bold:
      guard let img = NSImage(named: NSImage.touchBarTextBoldTemplateName) else { return nil }
      item.view = NSButton(image: img, target: self, action: #selector(bold))
      item.customizationLabel = "Bold"
      return item

    case .italic:
      guard let img = NSImage(named: NSImage.touchBarTextItalicTemplateName) else { return nil }
      item.view = NSButton(image: img, target: self, action: #selector(italic))
      item.customizationLabel = "Italic"
      return item

    case .code:
      item.view = NSButton(title: "<>", target: self, action: #selector(codeBlock))
      item.customizationLabel = "Code Block"
      return item

    case .math:
      item.view = NSButton(title: "$$", target: self, action: #selector(mathBlock))
      item.customizationLabel = "Math Block"
      return item

    case .image:
      guard let img = NSImage(named: "Image") else { return nil }
      item.view = NSButton(image: img, target: self, action: #selector(image))
      item.customizationLabel = "Image"
      return item

    default:
      return nil
    }
  }

}
