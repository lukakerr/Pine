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
  
  private func setDefaults(key: String, _ val: Any) {
    defaults.setValue(val, forKey: key)
  }
  
}

let preferences = Preferences.sharedInstance
