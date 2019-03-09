//
//  Utils.swift
//  Pine
//
//  Created by Luka Kerr on 1/3/19.
//  Copyright © 2019 Luka Kerr. All rights reserved.
//

import Foundation

class Utils {

  public static func setDefaultApplication() {
    guard
      let bundleId = Bundle.main.bundleIdentifier as CFString?,
      let utiTypes = Bundle.main.infoDictionary?["UTImportedTypeDeclarations"] as? [[String: Any]]
    else { return }

    for utiType in utiTypes {
      guard
        let tagSpec = utiType["UTTypeTagSpecification"] as? [String: Any],
        let exts = tagSpec["public.filename-extension"] as? [String]
        else { continue }

      var didError = false

      for ext in exts {
        guard
          let utiString = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            ext as CFString,
            nil
          )?.takeUnretainedValue()
        else { continue }

        let status = LSSetDefaultRoleHandlerForContentType(utiString, .all, bundleId)

        if status != kOSReturnSuccess {
          didError = true
        }
      }

      if didError {
        Alert.error(message: "There was a problem setting Pine as the Default Application")
      } else {
        Alert.success(message: "Successfully set Pine as the Default Application")
      }
    }
  }

}
