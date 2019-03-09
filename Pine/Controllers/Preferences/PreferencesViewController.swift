//
//  PreferencesViewController.swift
//  Pine
//
//  Created by Luka Kerr on 28/2/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  
  @IBOutlet weak var scrollView: NSScrollView!

  private var stackView: NSStackView!
  private var currentCategory: PreferenceCategory!

  private var uiStackView: UIStackView!
  private var markdownStackView: MarkdownStackView!
  private var documentStackView: DocumentStackView!

  override func viewDidLoad() {
    super.viewDidLoad()

    setupStackView()
    setupScrollView()

    uiStackView = UIStackView()
    markdownStackView = MarkdownStackView()
    documentStackView = DocumentStackView()

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
    scrollView.documentView = stackView
  }

  private func setupPreferenceViews() {
    guard let category = self.currentCategory else { return }

    for view in stackView.views {
      stackView.removeView(view)
    }

    var views: [NSView]

    switch category {
    case .ui:
      views = uiStackView.getViews()
      break
    case .markdown:
      views = markdownStackView.getViews()
      break
    case .document:
      views = documentStackView.getViews()
      break
    }

    for (index, view) in views.enumerated() {
      stackView.addArrangedSubview(view)

      // Add a seperator underneath all views except last
      if (index != views.count - 1) {
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
    let stackViewConstraints = [
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
    ]

    NSLayoutConstraint.activate(stackViewConstraints)
  }
  
}
