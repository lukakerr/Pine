//
//  Preferences.swift
//  Twig
//
//  Created by Luka Kerr on 29/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class Preferences {
  static let sharedInstance = Preferences()

  private init() {
    if defaults.object(forKey: "showPreviewOnStartup") != nil {
      showPreviewOnStartup = defaults.bool(forKey: "showPreviewOnStartup")
    }

    if defaults.object(forKey: "openNewDocumentOnStartup") != nil {
      openNewDocumentOnStartup = defaults.bool(forKey: "openNewDocumentOnStartup")
    }

    if defaults.object(forKey: "autosaveDocument") != nil {
      autosaveDocument = defaults.bool(forKey: "autosaveDocument")
    }

    if defaults.object(forKey: "verticalSplitView") != nil {
      verticalSplitView = defaults.bool(forKey: "verticalSplitView")
    }

    if defaults.object(forKey: "modernTitlebar") != nil {
      modernTitlebar = defaults.bool(forKey: "modernTitlebar")
    }

    if defaults.object(forKey: "useSystemAppearance") != nil {
      useSystemAppearance = defaults.bool(forKey: "useSystemAppearance")
    }

    if defaults.object(forKey: "showSidebar") != nil {
      showSidebar = defaults.bool(forKey: "showSidebar")
    }

    if defaults.object(forKey: "spellcheckEnabled") != nil {
      spellcheckEnabled = defaults.bool(forKey: "spellcheckEnabled")
    }
  }

  public var showPreviewOnStartup = true {
    willSet(newVal) {
      setDefaults(key: "showPreviewOnStartup", newVal)
    }
  }

  public var openNewDocumentOnStartup = true {
    willSet(newVal) {
      setDefaults(key: "openNewDocumentOnStartup", newVal)
    }
  }

  public var autosaveDocument = true {
    willSet(newVal) {
      setDefaults(key: "autosaveDocument", newVal)
    }
  }

  public var verticalSplitView = true {
    willSet(newVal) {
      setDefaults(key: "verticalSplitView", newVal)
    }
  }

  public var modernTitlebar = true {
    willSet(newVal) {
      setDefaults(key: "modernTitlebar", newVal)
    }
  }

  public var useSystemAppearance = false {
    willSet(newVal) {
      setDefaults(key: "useSystemAppearance", newVal)
    }
  }

  public var showSidebar = true {
    willSet(newVal) {
      setDefaults(key: "showSidebar", newVal)
    }
  }

  public var spellcheckEnabled = true {
    willSet(newVal) {
      setDefaults(key: "spellcheckEnabled", newVal)
    }
  }

  public var font: NSFont {
    get {
      let fontSize = defaults.double(forKey: "fontSize")
      if let fontName = defaults.string(forKey: "fontName"),
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
      setDefaults(key: "fontName", newValue.fontName)
      setDefaults(key: "fontSize", newValue.pointSize)
    }
  }

  fileprivate func setDefaults(key: String, _ val: Any) {
    defaults.setValue(val, forKey: key)
  }

}

let preferences = Preferences.sharedInstance
