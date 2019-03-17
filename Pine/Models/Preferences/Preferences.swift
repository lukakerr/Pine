//
//  Preferences.swift
//  Pine
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import cmark_gfm_swift

enum Preference {
  static let showPreviewOnStartup = PreferenceKey<Bool>("showPreviewOnStartup", defaultValue: true)
  static let openNewDocumentOnStartup = PreferenceKey<Bool>("openNewDocumentOnStartup", defaultValue: true)
  static let autosaveDocument = PreferenceKey<Bool>("autosaveDocument", defaultValue: true)
  static let verticalSplitView = PreferenceKey<Bool>("verticalSplitView", defaultValue: true)
  static let modernTitlebar = PreferenceKey<Bool>("modernTitlebar", defaultValue: true)
  static let useSystemAppearance = PreferenceKey<Bool>("useSystemAppearance", defaultValue: false)
  static let showSidebar = PreferenceKey<Bool>("showSidebar", defaultValue: true)
  static let spellcheckEnabled = PreferenceKey<Bool>("spellcheckEnabled", defaultValue: false)
  static let autoPairSyntax = PreferenceKey<Bool>("autoPairSyntax", defaultValue: true)
  static let useThemeColorForSidebar = PreferenceKey<Bool>("useThemeColorForSidebar", defaultValue: true)
  static let syncEditorAndPreview = PreferenceKey<Bool>("syncEditorAndPreview", defaultValue: false)

  // Font options
  static let fontSize = PreferenceKey<CGFloat>("fontSize", defaultValue: 14)
  static let fontName = PreferenceKey<String>("fontName", defaultValue: "Courier")

  // Markdown options
  static let markdownEmojis = PreferenceKey<Bool>("markdownEmojis", defaultValue: true)
  static let markdownTables = PreferenceKey<Bool>("markdownTables", defaultValue: true)
  static let markdownAutolink = PreferenceKey<Bool>("markdownAutolink", defaultValue: true)
  static let markdownMentions = PreferenceKey<Bool>("markdownMentions", defaultValue: true)
  static let markdownFootnotes = PreferenceKey<Bool>("markdownFootnotes", defaultValue: false)
  static let markdownCheckboxes = PreferenceKey<Bool>("markdownCheckboxes", defaultValue: true)
  static let markdownWikilinks = PreferenceKey<Bool>("markdownWikilinks", defaultValue: false)
  static let markdownStrikethrough = PreferenceKey<Bool>("markdownStrikethrough", defaultValue: true)

  // Autocomplete options
  static let htmlAutocomplete = PreferenceKey<Bool>("htmlAutocomplete", defaultValue: false)
  static let latexAutocomplete = PreferenceKey<Bool>("latexAutocomplete", defaultValue: false)
  static let markdownAutocomplete = PreferenceKey<Bool>("markdownAutocomplete", defaultValue: false)
}

class Preferences {
  static let shared = Preferences()

  private init() {
    theme.setFont(to: self.font)
  }

  subscript<T>(key: PreferenceKey<T>) -> T {
    get {
      return self.get(key)
    }

    set(newValue) {
      self.set(key, value: newValue)
    }
  }

  /// Get a preference given a key
  public func get<T>(_ preferenceKey: PreferenceKey<T>) -> T {
    guard
      defaults.object(forKey: preferenceKey.key) != nil,
      let value = defaults.object(forKey: preferenceKey.key),
      let typedValue = value as? T
    else {
      return preferenceKey.defaultValue
    }

    return typedValue
  }

  /// Set a preference given a key and value
  public func set<T>(_ preferenceKey: PreferenceKey<T>, value: Any) {
    defaults.setValue(value, forKey: preferenceKey.key)
  }

  // MARK: - Dynamic preferences

  public var markdownExtensions: [MarkdownExtensions] {
    var extensions: [MarkdownExtensions] = []

    if self[Preference.markdownEmojis] {
      extensions.append(.emoji)
    }

    if self[Preference.markdownTables] {
      extensions.append(.table)
    }

    if self[Preference.markdownAutolink] {
      extensions.append(.autolink)
    }

    if self[Preference.markdownMentions] {
      extensions.append(.mention)
    }

    if self[Preference.markdownCheckboxes] {
      extensions.append(.checkbox)
    }

    if self[Preference.markdownWikilinks] {
      extensions.append(.wikilink)
    }

    if self[Preference.markdownStrikethrough] {
      extensions.append(.strikethrough)
    }

    return extensions
  }

  public var markdownOptions: [MarkdownOptions] {
    var options: [MarkdownOptions] = []

    if self[Preference.markdownFootnotes] {
      options.append(.footnotes)
    }

    return options
  }

  public var font: NSFont {
    get {
      let fontSize = self[Preference.fontSize]
      let fontName = self[Preference.fontName]

      if let font = NSFont(name: fontName, size: CGFloat(fontSize)) {
        return font
      }

      // Default font not found, try to use a few standard ones
      for fontName in ["Courier", "Monaco", "Menlo", "SF Mono"] {
        if let font = NSFont(name: fontName, size: CGFloat(Preference.fontSize.defaultValue)) {
          return font
        }
      }

      return NSFont.monospacedDigitSystemFont(
        ofSize: CGFloat(Preference.fontSize.defaultValue),
        weight: .regular
      )
    }

    set {
      theme.setFont(to: newValue)
      self[Preference.fontName] = newValue.fontName
      self[Preference.fontSize] = newValue.pointSize
    }
  }

}

let preferences = Preferences.shared
