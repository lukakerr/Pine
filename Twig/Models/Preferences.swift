//
//  Preferences.swift
//  Twig
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

enum Keys {
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
  static let sharedInstance = Preferences()

  private init() {
    if defaults.object(forKey: Keys.showPreviewOnStartup) != nil {
      showPreviewOnStartup = defaults.bool(forKey: Keys.showPreviewOnStartup)
    }

    if defaults.object(forKey: Keys.openNewDocumentOnStartup) != nil {
      openNewDocumentOnStartup = defaults.bool(forKey: Keys.openNewDocumentOnStartup)
    }

    if defaults.object(forKey: Keys.autosaveDocument) != nil {
      autosaveDocument = defaults.bool(forKey: Keys.autosaveDocument)
    }

    if defaults.object(forKey: Keys.verticalSplitView) != nil {
      verticalSplitView = defaults.bool(forKey: Keys.verticalSplitView)
    }

    if defaults.object(forKey: Keys.modernTitlebar) != nil {
      modernTitlebar = defaults.bool(forKey: Keys.modernTitlebar)
    }

    if defaults.object(forKey: Keys.useSystemAppearance) != nil {
      useSystemAppearance = defaults.bool(forKey: Keys.useSystemAppearance)
    }

    if defaults.object(forKey: Keys.showSidebar) != nil {
      showSidebar = defaults.bool(forKey: Keys.showSidebar)
    }

    if defaults.object(forKey: Keys.spellcheckEnabled) != nil {
      spellcheckEnabled = defaults.bool(forKey: Keys.spellcheckEnabled)
    }

    if defaults.object(forKey: Keys.useThemeColorForSidebar) != nil {
      useThemeColorForSidebar = defaults.bool(forKey: Keys.useThemeColorForSidebar)
    }
  }

  public var showPreviewOnStartup = true {
    willSet(newVal) {
      setDefaults(key: Keys.showPreviewOnStartup, newVal)
    }
  }

  public var openNewDocumentOnStartup = true {
    willSet(newVal) {
      setDefaults(key: Keys.openNewDocumentOnStartup, newVal)
    }
  }

  public var autosaveDocument = true {
    willSet(newVal) {
      setDefaults(key: Keys.autosaveDocument, newVal)
    }
  }

  public var verticalSplitView = true {
    willSet(newVal) {
      setDefaults(key: Keys.verticalSplitView, newVal)
    }
  }

  public var modernTitlebar = true {
    willSet(newVal) {
      setDefaults(key: Keys.modernTitlebar, newVal)
    }
  }

  public var useSystemAppearance = false {
    willSet(newVal) {
      setDefaults(key: Keys.useSystemAppearance, newVal)
    }
  }

  public var showSidebar = true {
    willSet(newVal) {
      setDefaults(key: Keys.showSidebar, newVal)
    }
  }

  public var spellcheckEnabled = false {
    willSet(newVal) {
      setDefaults(key: Keys.spellcheckEnabled, newVal)
    }
  }

  public var useThemeColorForSidebar = true {
    willSet(newVal) {
      setDefaults(key: Keys.useThemeColorForSidebar, newVal)
    }
  }

  public var font: NSFont {
    get {
      let fontSize = defaults.double(forKey: Keys.fontSize)
      if let fontName = defaults.string(forKey: Keys.fontName),
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
      setDefaults(key: Keys.fontName, newValue.fontName)
      setDefaults(key: Keys.fontSize, newValue.pointSize)
    }
  }

  fileprivate func setDefaults(key: String, _ val: Any) {
    defaults.setValue(val, forKey: key)
  }

}

let preferences = Preferences.sharedInstance
