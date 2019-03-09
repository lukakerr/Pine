//
//  FileSaver.swift
//  Pine
//
//  Created by Luka Kerr on 23/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

class FileSaver {

  private var filetype: String
  private var data: Data

  init(data: Data, filetype: String) {
    self.data = data
    self.filetype = filetype
  }

  /// Save data to a user chosen location
  ///
  /// - Parameters:
  ///   - data: the raw data to save
  ///   - filetypes: allowed filetypes to save the data as
  ///   - type: the type of file, used only in the popup title
  public func save() throws {
    let dialog = NSSavePanel()

    dialog.title = "Export file"
    dialog.allowedFileTypes = [filetype]
    dialog.canCreateDirectories = true

    if dialog.runModal() == .OK {
      guard let url = dialog.url else { throw SaveError.URLNotFound }

      do {
        try data.write(to: url, options: .atomic)
      } catch {
        throw SaveError.unableToWrite
      }
    }
  }

}
