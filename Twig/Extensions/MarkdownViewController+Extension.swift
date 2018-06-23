//
//  MarkdownViewController+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 21/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension MarkdownViewController {

  public func getSplitViewController() -> NSSplitViewController? {
    return self.parent as? NSSplitViewController
  }

  public func getPreviewViewController() -> PreviewViewController? {
    return self.getSplitViewController()?.splitViewItems.last?.viewController as? PreviewViewController
  }

}
