//
//  PreferencesViewController.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

  private let FIXED_HEIGHT: CGFloat = 400

  private var scrollView: NSScrollView!
  private var stackView: NSStackView!
  private var currentCategory: PreferenceCategory!

  private lazy var generalStackView = GeneralStackView()
  private lazy var uiStackView = UIStackView()
  private lazy var editorStackView = EditorStackView()
  private lazy var previewStackView = PreviewStackView()
  private lazy var markdownStackView = MarkdownStackView()
  private lazy var documentStackView = DocumentStackView()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupStackView()
    setupScrollView()

    view.addSubview(scrollView)

    setupPreferenceViews()
    setupConstraints()
  }

  public func setCategory(category: PreferenceCategory) {
    self.currentCategory = category

    if isViewLoaded {
      setupPreferenceViews()
    }
  }

  private func setupStackView() {
    stackView = NSStackView()
    stackView.spacing = 15.0
    stackView.orientation = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
  }

  private func setupScrollView() {
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.drawsBackground = false
    scrollView.documentView = stackView
    scrollView.translatesAutoresizingMaskIntoConstraints = false
  }

  private func setupPreferenceViews() {
    guard let category = self.currentCategory else { return }

    for view in stackView.views {
      stackView.removeView(view)
    }

    var views: [NSView]

    switch category {
    case .general:
      views = generalStackView.getViews()
    case .ui:
      views = uiStackView.getViews()
    case .editor:
      views = editorStackView.getViews()
    case .preview:
      views = previewStackView.getViews()
    case .markdown:
      views = markdownStackView.getViews()
    case .document:
      views = documentStackView.getViews()
    }

    for (index, view) in views.enumerated() {
      stackView.addArrangedSubview(view)

      // Add a seperator underneath all views except last
      if index != views.count - 1 {
        let hr = NSBox()
        hr.boxType = .separator

        stackView.addArrangedSubview(hr)
      }

      let viewConstraints = [
        view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
      ]

      NSLayoutConstraint.activate(viewConstraints)
    }
  }

  private func setupConstraints() {
    let viewConstraints = [
      view.heightAnchor.constraint(equalToConstant: FIXED_HEIGHT)
    ]

    let scrollViewConstraints = [
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    let stackViewConstraints = [
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: FIXED_HEIGHT)
    ]

    NSLayoutConstraint.activate(viewConstraints)
    NSLayoutConstraint.activate(scrollViewConstraints)
    NSLayoutConstraint.activate(stackViewConstraints)
  }

}
