//
//  ToolbarItems.swift
//  Pine
//
//  Created by Luka Kerr on 19/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

final class ToolbarData {

  public var toolbarIdentifiers: [NSToolbarItem.Identifier] {
    return self.toolbarItems.compactMap { $0.identifier }
  }

  public var uniqueToolbarIdentifiers: [NSToolbarItem.Identifier] {
    return Array(Set(toolbarIdentifiers))
  }

  public let toolbarItems: [ToolbarItemInfo] = [
    ToolbarItemInfo(identifier: .toggleSidebar),
    ToolbarItemInfo(identifier: .space),
    ToolbarItemInfo(
      title: "Headings",
      identifier: .headings,
      children: [
        ToolbarItemInfo(
          title: "H1",
          iconTitle: "H1",
          action: #selector(MarkdownViewController.h1),
          identifier: .h1
        ),
        ToolbarItemInfo(
          title: "H2",
          iconTitle: "H2",
          action: #selector(MarkdownViewController.h2),
          identifier: .h2
        ),
        ToolbarItemInfo(
          title: "H3",
          iconTitle: "H3",
          action: #selector(MarkdownViewController.h3),
          identifier: .h3
        )
      ]
    ),
    ToolbarItemInfo(identifier: .space),
    ToolbarItemInfo(
      title: "Text Formats",
      identifier: .formats,
      children: [
        ToolbarItemInfo(
          title: "Bold",
          icon: NSImage.Name(stringLiteral: "Bold"),
          action: #selector(MarkdownViewController.bold),
          identifier: .bold
        ),
        ToolbarItemInfo(
          title: "Italic",
          icon: NSImage.Name(stringLiteral: "Italic"),
          action: #selector(MarkdownViewController.italic),
          identifier: .italic
        ),
        ToolbarItemInfo(
          title: "Strikethrough",
          icon: NSImage.Name(stringLiteral: "Strikethrough"),
          action: #selector(MarkdownViewController.strikethrough),
          identifier: .strikethrough
        )
      ]
    ),
    ToolbarItemInfo(identifier: .space),
    ToolbarItemInfo(
      title: "Code",
      iconTitle: "<>",
      action: #selector(MarkdownViewController.code),
      identifier: .code
    ),
    ToolbarItemInfo(
      title: "Math",
      iconTitle: "$$",
      action: #selector(MarkdownViewController.math),
      identifier: .math
    ),
    ToolbarItemInfo(
      title: "Image",
      icon: NSImage.Name(stringLiteral: "Image"),
      action: #selector(MarkdownViewController.image),
      identifier: .image
    ),
    ToolbarItemInfo(identifier: .flexibleSpace),
    ToolbarItemInfo(
      title: "Preview",
      icon: NSImage.listViewTemplateName,
      action: #selector(PineWindowController.togglePreview),
      identifier: .togglePreview
    )
  ]

}
