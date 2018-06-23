//
//  FileSaver.swift
//  Twig
//
//  Created by Luka Kerr on 23/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class FileSaver {
  
  private var filetypes: [String]
  private var data: Data
  
  init(data: Data, filetypes: [String]) {
    self.data = data
    self.filetypes = filetypes
  }
  
  /// Save data to a user chosen location
  ///
  /// - Parameters:
  ///   - data: the raw data to save
  ///   - filetypes: allowed filetypes to save the data as
  ///   - type: the type of file, used only in the popup title
  public func save() {
    let dialog = NSSavePanel()
    
    dialog.title = "Export file"
    dialog.allowedFileTypes = self.filetypes
    dialog.canCreateDirectories = true
    
    if (dialog.runModal() == .OK) {
      if let result = dialog.url {
        do {
          try self.data.write(to: result, options: .atomic)
        } catch {
          print("error:", error)
        }
      }
    }
  }
  
}
