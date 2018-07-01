//
//  FileSystemItem.swift
//  Twig
//
//  Created by Luka Kerr on 30/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

final class FileSystemItem {

  fileprivate var relativePath: String!
  fileprivate var parent: FileSystemItem?
  lazy fileprivate var children: [FileSystemItem] = self.getChildren()

  var fullPath: String {
    guard
      let parent = self.parent,
      let url = URL(string: parent.fullPath)?.appendingPathComponent(self.relativePath)
    else { return self.relativePath }

    return url.absoluteString
  }

  var url: URL {
    return URL(string: self.fullPath)!
  }

  var fileUrl: URL {
    return URL(string: "file://" + self.fullPath)!
  }

  var isDirectory: Bool {
    var isDir: ObjCBool = false
    FileManager.default.fileExists(atPath: self.fullPath, isDirectory: &isDir)
    return isDir.boolValue
  }

  convenience init() {
    self.init(path: "/", parent: nil)
  }

  init(path: String, parent: FileSystemItem?) {
    self.relativePath = URL(fileURLWithPath: path).lastPathComponent
    self.parent = parent
  }

  // MARK: - Public methods

  public func getChild(at index: Int) -> FileSystemItem {
    return children[index]
  }

  public func getNumberOfChildren() -> Int {
    return children.count
  }

  public func getName() -> String {
    return self.relativePath
  }

  // MARK: - Private methods

  private func getChildren() -> [FileSystemItem] {
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    var children = [FileSystemItem]()

    let valid = fileManager.fileExists(atPath: self.fullPath, isDirectory: &isDirectory)

    if valid && isDirectory.boolValue {
      if let contents = try? fileManager.contentsOfDirectory(atPath: self.fullPath) {
        contents.filter({
          // The child is a single markdown document
          if $0.isMarkdown { return true }

          guard let path = URL(string: self.fullPath)?.appendingPathComponent($0) else { return false }
          let enumerator = fileManager.enumerator(atPath: path.absoluteString)

          // Iterate over all files/folders of the child, checking if at least one is a markdown document
          while let element = enumerator?.nextObject() as? String {
            if element.isMarkdown {
              return true
            }
          }

          // Didn't find any markdown documents, so remove this child
          return false
        }).forEach({
          let child = FileSystemItem(path: $0, parent: self)

          var kidIsDirectory: ObjCBool = false
          fileManager.fileExists(atPath: child.fullPath, isDirectory: &kidIsDirectory)

          // Only add if the child is a markdown document, or a directory
          if child.relativePath.isMarkdown || kidIsDirectory.boolValue {
            children.append(child)
          }
        })
      }
      return children
    }
    return []
  }

  // MARK: - Static methods

  static func createParents(url: URL) -> FileSystemItem {
    let parentUrl = url.deletingLastPathComponent()
    let path = parentUrl.absoluteString

    if path.isBaseFile {
      return FileSystemItem()
    }

    return FileSystemItem(path: path, parent: createParents(url: parentUrl))
  }

}
