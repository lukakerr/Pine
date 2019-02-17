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
  static let useThemeColorForSidebar = "useThemeColorForSidebar"
  static let fontSize = "fontSize"
  static let fontName = "fontName"
}

class Preferences {
  static let shared = Preferences()

  private init() {
    if defaults.object(forKey: PreferencesKeys.showPreviewOnStartup) != nil {
      showPreviewOnStartup = defaults.bool(forKey: PreferencesKeys.showPreviewOnStartup)
    }

    if defaults.object(forKey: PreferencesKeys.openNewDocumentOnStartup) != nil {
      openNewDocumentOnStartup = defaults.bool(forKey: PreferencesKeys.openNewDocumentOnStartup)
    }

    if defaults.object(forKey: PreferencesKeys.autosaveDocument) != nil {
      autosaveDocument = defaults.bool(forKey: PreferencesKeys.autosaveDocument)
    }

    if defaults.object(forKey: PreferencesKeys.verticalSplitView) != nil {
      verticalSplitView = defaults.bool(forKey: PreferencesKeys.verticalSplitView)
    }

    if defaults.object(forKey: PreferencesKeys.modernTitlebar) != nil {
      modernTitlebar = defaults.bool(forKey: PreferencesKeys.modernTitlebar)
    }

    if defaults.object(forKey: PreferencesKeys.useSystemAppearance) != nil {
      useSystemAppearance = defaults.bool(forKey: PreferencesKeys.useSystemAppearance)
    }

    if defaults.object(forKey: PreferencesKeys.showSidebar) != nil {
      showSidebar = defaults.bool(forKey: PreferencesKeys.showSidebar)
    }

    if defaults.object(forKey: PreferencesKeys.spellcheckEnabled) != nil {
      spellcheckEnabled = defaults.bool(forKey: PreferencesKeys.spellcheckEnabled)
    }

    if defaults.object(forKey: PreferencesKeys.useThemeColorForSidebar) != nil {
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

}

let preferences = Preferences.shared
