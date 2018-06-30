//
//  FileSystemItem.swift
//  Twig
//
//  Created by Luka Kerr on 30/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

final class FileSystemItem {

  var relativePath: String!
  var parent: FileSystemItem?

  var children: [FileSystemItem] {
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    var kids = [FileSystemItem]()

    let valid = fileManager.fileExists(atPath: self.fullPath, isDirectory: &isDirectory)

    if valid && isDirectory.boolValue {
      if let contents = try? fileManager.contentsOfDirectory(atPath: self.fullPath) {
        contents.forEach {
          let kid = FileSystemItem(path: $0, parent: self)

          var kidIsDirectory: ObjCBool = false
          fileManager.fileExists(atPath: kid.fullPath, isDirectory: &kidIsDirectory)

          if kid.relativePath.hasSuffix(".md") || kidIsDirectory.boolValue {
            kids.append(kid)
          }
        }
      }
      return kids
    }
    return []
  }

  var fullPath: String {
    guard
      let parent = self.parent,
      let url = NSURL(string: parent.fullPath)?.appendingPathComponent(self.relativePath)
    else { return self.relativePath }

    return url.absoluteString
  }

  var url: URL {
    return URL(string: "file://" + self.fullPath)!
  }

  convenience init() {
    self.init(path: "/", parent: nil)
  }

  init(path: String, parent: FileSystemItem?) {
    self.relativePath = NSURL(fileURLWithPath: path).lastPathComponent
    self.parent = parent
  }

  public func getChild(at index: Int) -> FileSystemItem {
    return children[index]
  }

  public func getNumberOfChildren() -> Int {
    return children.count
  }

  static func createParents(url: URL) -> FileSystemItem {
    let parentUrl = url.deletingLastPathComponent()
    let path = parentUrl.absoluteString

    if path == "file:///" {
      return FileSystemItem()
    }

    return FileSystemItem(path: path, parent: createParents(url: parentUrl))
  }

}
