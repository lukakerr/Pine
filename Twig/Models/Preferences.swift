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
      self.showPreviewOnStartup = defaults.bool(forKey: "showPreviewOnStartup")
    }
    
    if defaults.object(forKey: "openNewDocumentOnStartup") != nil {
      self.openNewDocumentOnStartup = defaults.bool(forKey: "openNewDocumentOnStartup")
    }
    
    if defaults.object(forKey: "autosaveDocument") != nil {
      self.autosaveDocument = defaults.bool(forKey: "autosaveDocument")
    }
    
    if defaults.object(forKey: "transparentEditingView") != nil {
      self.transparentEditingView = defaults.bool(forKey: "transparentEditingView")
    }
    
    if defaults.object(forKey: "verticalSplitView") != nil {
      self.verticalSplitView = defaults.bool(forKey: "verticalSplitView")
    }
    
    if defaults.object(forKey: "modernTitlebar") != nil {
      self.modernTitlebar = defaults.bool(forKey: "modernTitlebar")
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
  
  public var transparentEditingView = false {
    willSet(newVal) {
      // transparentEditingView looks best without preview showing
      self.showPreviewOnStartup = !newVal
      setDefaults(key: "transparentEditingView", newVal)
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
  
  private func setDefaults(key: String, _ val: Any) {
    defaults.setValue(val, forKey: key)
  }
  
}

let preferences = Preferences.sharedInstance
