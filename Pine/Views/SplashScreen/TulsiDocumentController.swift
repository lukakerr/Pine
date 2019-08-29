import AppKit

// Document controller for customization of the open panel.
final class SplashScreenDocumentController: NSDocumentController {

  override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
    openPanel.message = "OpenProject"
    return super.runModalOpenPanel(openPanel, forTypes: types)
  }

}
