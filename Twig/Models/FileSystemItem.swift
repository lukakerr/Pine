//
//  FileSystemItem.swift
//  Twig
//
//  Created by Luka Kerr on 30/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

final class FileSystemItem {

  private var relativePath: String!
  private var parent: FileSystemItem?
  lazy var children: [FileSystemItem] = self.getChildren()

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

  public func getName() -> String {
    return self.relativePath
  }

  private func getChildren() -> [FileSystemItem] {
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    var kids = [FileSystemItem]()

    let valid = fileManager.fileExists(atPath: self.fullPath, isDirectory: &isDirectory)

    if valid && isDirectory.boolValue {
      if let contents = try? fileManager.contentsOfDirectory(atPath: self.fullPath) {
        contents.filter({
          if $0.hasSuffix(".md") { return true }

          guard let path = URL(string: self.fullPath)?.appendingPathComponent($0) else { return false }
          let enumerator = fileManager.enumerator(atPath: path.absoluteString)

          while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".md") {
              return true
            }
          }

          return false
        }).forEach({
          let kid = FileSystemItem(path: $0, parent: self)

          var kidIsDirectory: ObjCBool = false
          fileManager.fileExists(atPath: kid.fullPath, isDirectory: &kidIsDirectory)

          if kid.relativePath.hasSuffix(".md") || kidIsDirectory.boolValue {
            kids.append(kid)
          }
        })
      }
      return kids
    }
    return []
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
