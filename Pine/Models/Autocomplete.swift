//
//  Autocomplete.swift
//  Pine
//
//  Created by Luka Kerr on 16/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Foundation

class Autocomplete {

  static let shared = Autocomplete()

  private var htmlWords: [String]
  private var latexWords: [String]
  private var markdownWords: [String]

  private init() {
    guard
      let htmlFile = Bundle.main.path(forResource: "autocomplete/html", ofType: "txt"),
      let latexFile = Bundle.main.path(forResource: "autocomplete/latex", ofType: "txt"),
      let markdownFile = Bundle.main.path(forResource: "autocomplete/markdown", ofType: "txt"),
      let htmlContents = try? String(contentsOf: URL(fileURLWithPath: htmlFile), encoding: .utf8),
      let latexContents = try? String(contentsOf: URL(fileURLWithPath: latexFile), encoding: .utf8),
      let markdownContents = try? String(contentsOf: URL(fileURLWithPath: markdownFile), encoding: .utf8)
    else {
      self.htmlWords = []
      self.latexWords = []
      self.markdownWords = []
      return
    }

    self.htmlWords = htmlContents.components(separatedBy: "\n")
    self.latexWords = latexContents.components(separatedBy: "\n")
    self.markdownWords = markdownContents.components(separatedBy: "\n")
  }

  public func getMatches(for string: String) -> [String] {
    if string.count == 0 {
      return []
    }

    var matches: [String] = []

    func filtered(_ arr: [String]) -> [String] {
      return arr.filter { $0.starts(with: string) && $0 != string }
    }

    if preferences[.markdownAutocomplete] {
      matches.append(contentsOf: filtered(markdownWords))
    }

    if preferences[.latexAutocomplete] {
      matches.append(contentsOf: filtered(latexWords))
    }

    if preferences[.htmlAutocomplete] {
      matches.append(contentsOf: filtered(htmlWords))
    }

    return matches
  }

}

let autocomplete = Autocomplete.shared
