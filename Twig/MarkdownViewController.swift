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

let DEFAULT_FONT = NSFont(name: "Courier", size: CGFloat(18))

class MarkdownViewController: NSViewController, NSTextViewDelegate {

  @IBOutlet var markdownTextView: NSTextView!
  
  private let highlightr = Highlightr()!
  private var debouncedGeneratePreview: Debouncer!
  
  // Cocoa binding for text inside markdownTextView
  @objc var attributedMarkdownTextInput: NSAttributedString {
    get {
      return NSAttributedString(string: markdownTextView.string)
    }
    set {
      syntaxHighlight(newValue.string)
      debouncedGeneratePreview.call()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup notification observer for theme change
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.themeChanged),
      name: NSNotification.Name(rawValue: "changeThemeNotification"),
      object: nil
    )
    
    debouncedGeneratePreview = Debouncer(delay: 0.2) {
      self.generatePreview(self.markdownTextView.string)
    }
    
    if let splitViewController = self.parent as? NSSplitViewController,
      let previewViewController = splitViewController.splitViewItems.last {
      previewViewController.isCollapsed = !preferences.showPreviewOnStartup
    }
    
    markdownTextView.delegate = self
    markdownTextView.font = DEFAULT_FONT
    markdownTextView.insertionPointColor = .gray
    markdownTextView.textContainerInset = NSSize(width: 10.0, height: 10.0)
  }
  
  override func viewDidAppear() {
    highlightr.setTheme(to: theme.syntax)
    setBackgroundColor()
    generatePreview(markdownTextView.string)
  }
  
  override var acceptsFirstResponder: Bool {
    return true
  }
  
  @IBAction func togglePreview(sender: NSMenuItem) {
    if let splitViewController = self.parent as? NSSplitViewController,
      let previewViewController = splitViewController.splitViewItems.last {
      previewViewController.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
      previewViewController.animator().isCollapsed = !previewViewController.isCollapsed
    }
  }
  
  // Syntax highlight the given markdown string and insert into text view
  private func syntaxHighlight(_ string: String) {
    self.highlightr.setTheme(to: theme.syntax)
    
    DispatchQueue.global(qos: .userInitiated).async {
      let highlightedCode = self.highlightr.highlight(string, as: "markdown")
      
      if let syntaxHighlighted = highlightedCode {
        let code = NSMutableAttributedString(attributedString: syntaxHighlighted)
        if let font = DEFAULT_FONT {
          code.withFont(font)
          
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
  }
  
  private func generatePreview(_ string: String) {
    DispatchQueue.global(qos: .userInitiated).async {
      if let splitViewController = self.parent as? NSSplitViewController,
        let previewView = splitViewController.splitViewItems.last {
        let previewViewController = previewView.viewController as? PreviewViewController
        
        if previewView.isCollapsed {
          return
        }
        
        if let parsed = try? Down(markdownString: string).toHTML() {
          html.contents = parsed
          DispatchQueue.main.async {
            previewViewController?.captureScroll() {
              previewViewController?.webPreview.loadHTMLString(html.getHTML(), baseURL: nil)
            }
          }
        }
      }
    }
  }
  
  // On theme change, update window appearance and reparse with possible new syntax
  @objc private func themeChanged(notification: Notification?) {
    syntaxHighlight(markdownTextView.string)
    setBackgroundColor()
    generatePreview(markdownTextView.string)
  }
  
  private func setBackgroundColor() {
    guard let color = highlightr.theme.themeBackgroundColor else {
      return
    }
    
    theme.background = color.hex
    
    if color.isDark {
      theme.code = color.lighter.hex
      theme.text = "#FFF"
      self.view.window?.appearance = NSAppearance(named: .vibrantDark)
    } else {
      theme.code = color.darker.hex
      theme.text = "#000"
      self.view.window?.appearance = NSAppearance(named: .vibrantLight)
    }
    self.view.window?.backgroundColor = color
  }

}
