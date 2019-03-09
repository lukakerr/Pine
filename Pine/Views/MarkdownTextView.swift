//
//  MarkdownTextView.swift
//  Pine
//
//  Created by Luka Kerr on 8/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class MarkdownTextView: NSTextView {

  override func paste(_ sender: Any?) {
    let fileURLs = NSPasteboard.general.readObjects(
      forClasses: [NSURL.self],
      options: [.urlReadingFileURLsOnly: 1]
    ) as? [URL]

    let images = fileURLs?.filter { $0.isImage }

    if let markdownImages = images, markdownImages.count > 0 {
      self.pasteImages(markdownImages)
      return
    }

    super.paste(sender)
  }

  private func pasteImages(_ images: [URL]) {
    for image in images {
      let path = image.absoluteString
      let name = image.lastPathComponent

      self.replace(left: "![\(name)](\(path))\n")
    }
  }

}
