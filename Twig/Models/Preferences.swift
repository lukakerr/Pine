//
//  Preferences.swift
//  Twig
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

enum PreferencesKeys {
  static let showPreviewOnStartup = "showPreviewOnStartup"
  static let openNewDocumentOnStartup = "openNewDocumentOnStartup"
  static let autosaveDocument = "autosaveDocument"
  static let verticalSplitView = "verticalSplitView"
  static let modernTitlebar = "modernTitlebar"
  static let useSystemAppearance = "useSystemAppearance"
  static let showSidebar = "showSidebar"
  static let spellcheckEnabled = "spellcheckEnabled"
  static let autoPairSyntax = "autoPairSyntax"
  static let useThemeColorForSidebar = "useThemeColorForSidebar"
  static let fontSize = "fontSize"
  static let fontName = "fontName"
}

class Preferences {
  static let shared = Preferences()

  private init() {
    if exists(PreferencesKeys.showPreviewOnStartup) {
      showPreviewOnStartup = defaults.bool(forKey: PreferencesKeys.showPreviewOnStartup)
    }

    if exists(PreferencesKeys.openNewDocumentOnStartup) {
      openNewDocumentOnStartup = defaults.bool(forKey: PreferencesKeys.openNewDocumentOnStartup)
    }

    if exists(PreferencesKeys.autosaveDocument) {
      autosaveDocument = defaults.bool(forKey: PreferencesKeys.autosaveDocument)
    }

    if exists(PreferencesKeys.verticalSplitView) {
      verticalSplitView = defaults.bool(forKey: PreferencesKeys.verticalSplitView)
    }

    if exists(PreferencesKeys.modernTitlebar) {
      modernTitlebar = defaults.bool(forKey: PreferencesKeys.modernTitlebar)
    }

    if exists(PreferencesKeys.useSystemAppearance) {
      useSystemAppearance = defaults.bool(forKey: PreferencesKeys.useSystemAppearance)
    }

    if exists(PreferencesKeys.showSidebar) {
      showSidebar = defaults.bool(forKey: PreferencesKeys.showSidebar)
    }

    if exists(PreferencesKeys.spellcheckEnabled) {
      spellcheckEnabled = defaults.bool(forKey: PreferencesKeys.spellcheckEnabled)
    }

    if exists(PreferencesKeys.autoPairSyntax) {
      autoPairSyntax = defaults.bool(forKey: PreferencesKeys.autoPairSyntax)
    }

    if exists(PreferencesKeys.useThemeColorForSidebar) {
      useThemeColorForSidebar = defaults.bool(forKey: PreferencesKeys.useThemeColorForSidebar)
    }

    theme.setFont(to: self.font)
  }

  public var showPreviewOnStartup = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.showPreviewOnStartup, newVal)
    }
  }

  public var openNewDocumentOnStartup = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.openNewDocumentOnStartup, newVal)
    }
  }

  public var autosaveDocument = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.autosaveDocument, newVal)
    }
  }

  public var verticalSplitView = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.verticalSplitView, newVal)
    }
  }

  public var modernTitlebar = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.modernTitlebar, newVal)
    }
  }

  public var useSystemAppearance = false {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.useSystemAppearance, newVal)
    }
  }

  public var showSidebar = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.showSidebar, newVal)
    }
  }

  public var spellcheckEnabled = false {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.spellcheckEnabled, newVal)
    }
  }

  public var autoPairSyntax = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.autoPairSyntax, newVal)
    }
  }

  public var useThemeColorForSidebar = true {
    willSet(newVal) {
      setDefaults(key: PreferencesKeys.useThemeColorForSidebar, newVal)
    }
  }

  public var font: NSFont {
    get {
      let fontSize = defaults.double(forKey: PreferencesKeys.fontSize)
      if let fontName = defaults.string(forKey: PreferencesKeys.fontName),
        let font = NSFont(name: fontName, size: CGFloat(fontSize)) {
        return font
      }

      // default font not found, try to use a few standard ones
      for fontName in ["Courier", "Monaco", "Menlo", "SF Mono"] {
        if let font = NSFont(name: fontName, size: CGFloat(18)) {
          return font
        }
      }

      return NSFont.monospacedDigitSystemFont(ofSize: CGFloat(18), weight: .regular)
    }

    set {
      theme.setFont(to: newValue)
      setDefaults(key: PreferencesKeys.fontName, newValue.fontName)
      setDefaults(key: PreferencesKeys.fontSize, newValue.pointSize)
    }
  }

  fileprivate func setDefaults(key: String, _ val: Any) {
    defaults.setValue(val, forKey: key)
  }

  fileprivate func exists(_ key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
  }

}

let preferences = Preferences.shared
