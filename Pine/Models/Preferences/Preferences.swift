//
//  Preferences.swift
//  Pine
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa
import cmark_gfm_swift

extension PreferenceKeys {
  static let showPreviewOnStartup = PreferenceKey<Bool>("showPreviewOnStartup", defaultValue: true)
  static let autosaveDocument = PreferenceKey<Bool>("autosaveDocument", defaultValue: true)
  static let verticalSplitView = PreferenceKey<Bool>("verticalSplitView", defaultValue: true)
  static let modernTitlebar = PreferenceKey<Bool>("modernTitlebar", defaultValue: true)
  static let useSystemAppearance = PreferenceKey<Bool>("useSystemAppearance", defaultValue: false)
  static let showSidebar = PreferenceKey<Bool>("showSidebar", defaultValue: true)
  static let spellcheckEnabled = PreferenceKey<Bool>("spellcheckEnabled", defaultValue: false)
  static let autoPairSyntax = PreferenceKey<Bool>("autoPairSyntax", defaultValue: true)
  static let useThemeColorForSidebar = PreferenceKey<Bool>("useThemeColorForSidebar", defaultValue: true)
  static let syncEditorAndPreview = PreferenceKey<Bool>("syncEditorAndPreview", defaultValue: false)
  static let showToolbar = PreferenceKey<Bool>("showToolbar", defaultValue: false)
  static let showInvisibles = PreferenceKey<Bool>("showInvisibles", defaultValue: false)
  static let scrollPastEnd = PreferenceKey<Bool>("scrollPastEnd", defaultValue: false)
  static let writingDirection = PreferenceKey<Int>("writingDirection", defaultValue: NSWritingDirection.natural.rawValue)

  // AppDelegate options
  static let openNewDocumentOnStartup = PreferenceKey<Bool>("openNewDocumentOnStartup", defaultValue: true)
  static let terminateAfterLastWindowClosed = PreferenceKey<Bool>("terminateAfterLastWindowClosed", defaultValue: false)

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

    set {
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

  /// Given a boolean preference map, a key and value, set the value if found in the map
  public func setFromBoolMap(_ map: BoolPreferenceMap, key: String, value: Bool) {
    if let ext = map[key] {
      self[ext] = value
      NotificationCenter.send(.preferencesChanged)
    }
  }

  // MARK: - Dynamic preferences

  public var markdownExtensions: [MarkdownExtensions] {
    var extensions: [MarkdownExtensions] = []

    if self[.markdownEmojis] {
      extensions.append(.emoji)
    }

    if self[.markdownTables] {
      extensions.append(.table)
    }

    if self[.markdownAutolink] {
      extensions.append(.autolink)
    }

    if self[.markdownMentions] {
      extensions.append(.mention)
    }

    if self[.markdownCheckboxes] {
      extensions.append(.checkbox)
    }

    if self[.markdownWikilinks] {
      extensions.append(.wikilink)
    }

    if self[.markdownStrikethrough] {
      extensions.append(.strikethrough)
    }

    return extensions
  }

  public var markdownOptions: [MarkdownOptions] {
    var options: [MarkdownOptions] = []

    if self[.markdownFootnotes] {
      options.append(.footnotes)
    }

    return options
  }

  public var font: NSFont {
    get {
      let fontSize = CGFloat(self[.fontSize])
      let fontName = self[.fontName]

      if let font = NSFont(name: fontName, size: fontSize) {
        return font
      }

      // Default font not found, try to use a few standard ones
      for fontName in ["Courier", "Monaco", "Menlo", "SF Mono"] {
        if let font = NSFont(name: fontName, size: fontSize) {
          return font
        }
      }

      return NSFont.monospacedDigitSystemFont(
        ofSize: fontSize,
        weight: .regular
      )
    }

    set {
      theme.setFont(to: newValue)
      self[.fontName] = newValue.fontName
      self[.fontSize] = newValue.pointSize
    }
  }

  public var writingDirection: NSWritingDirection {
    get {
      let value = self[.writingDirection]
      return NSWritingDirection(rawValue: value) ?? .natural
    }

    set {
      self[.writingDirection] = newValue.rawValue
    }
  }

}

let preferences = Preferences.shared
