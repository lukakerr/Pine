//
//  Document.swift
//  Twig
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class Document: NSDocument {
  
  var markdownVC: MarkdownViewController?
  
  private var fileData: Data?
  private var fileUrl: URL?

  override init() {
    super.init()
  }
  
  // Autosaving
  override class var autosavesInPlace: Bool {
    return preferences.autosaveDocument
  }

  // Handles changes from another application
  override func presentedItemDidChange() {
  }
  
  override func makeWindowControllers() {
    // Returns the Storyboard that contains your Document window.
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let windowController = storyboard.instantiateController(
      withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")
    ) as! NSWindowController
    self.markdownVC = windowController.contentViewController?.children[0] as? MarkdownViewController
    self.addWindowController(windowController)
    self.setContents()
  }

  // Returns data used to save the file
  override func data(ofType typeName: String) throws -> Data {
    guard let data = self.markdownVC?.markdownTextView.textStorage?.string.data(using: .utf8) else {
      throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    return data
  }
  
  // Reads from a file URL and updates the class variable fileData
  override func read(from url: URL, ofType typeName: String) throws {
    let contents = try? String(contentsOf: url, encoding: .utf8)
    self.fileUrl = url
    self.fileData = contents?.data(using: .utf8)
  }
  
  private func setContents() {
    if let data = self.fileData, let contents = String(data: data, encoding: .utf8) {
      self.markdownVC?.attributedMarkdownTextInput = NSAttributedString(string: contents)
    }
  }

}

