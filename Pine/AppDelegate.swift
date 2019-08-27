//
//  AppDelegate.swift
//  Pine
//
//  Created by Luka Kerr on 25/4/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var splashScreenWindowController: SplashScreenWindowController! = nil
    
    
    /// The key window's `WindowController` instance
    private var keyWindowController: PineWindowController? {
        return NSApp.keyWindow?.windowController as? PineWindowController
    }
    
    override init() {
        // Hacky way to get in before NSDocumentController instantiates its shared instance.
        // This way we can subclass NSDocumentController and use our class as the shared instance
        //    _ = DocumentController.init()
        
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if #available(OSX 10.12.2, *) {
            NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
        _ = TulsiDocumentController()
    }
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        splashScreenWindowController = SplashScreenWindowController()
        splashScreenWindowController.showWindow(self)
        return true
    }
    
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
        
        //    return preferences[.openNewDocumentOnStartup]
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return preferences[.terminateAfterLastWindowClosed]
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        let fileURLs = filenames.compactMap { URL(fileURLWithPath: $0) }
        openFiles(files: fileURLs)
        
        sender.reply(toOpenOrPrint: .success)
    }
    
    // MARK: - First responder methods that can be called anywhere in the application
    
    @IBAction func openFileOrFolder(_ sender: Any?) {
        let dialog = NSOpenPanel()
        
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = true
        dialog.showsHiddenFiles = true
        dialog.canCreateDirectories = true
        dialog.canChooseDirectories = true
        dialog.allowedFileTypes = ["md", "markdown"]
        
        guard
            dialog.runModal() == .OK,
            let result = dialog.url
            else { return }
        
        openFiles(files: [result])
    }
    
    private func openFiles(files: [URL]) {
        for file in files {
            var isDirectory: ObjCBool = false
            
            // Ensure the file or folder exists
            guard FileManager.default.fileExists(
                atPath: file.path,
                isDirectory: &isDirectory
                ) else { continue }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let parent = FileSystemItem.createParents(url: file)
                let newItem = FileSystemItem(path: file.absoluteString, parent: parent)
                
                DispatchQueue.main.async {
                    openDocuments.addDocument(newItem)
                    
                    // Don't have a window open
                    if NSApp.keyWindow == nil {
                        DocumentController.shared.newDocument(self)
                    }
                    
                    if isDirectory.boolValue {
                        self.keyWindowController?.syncWindowSidebars()
                    } else {
                        DocumentController.shared.openDocument(
                            withContentsOf: file,
                            display: true,
                            completionHandler: { _, _, _  in
                                Utils.getCurrentMainWindowController()?.window?.makeKeyAndOrderFront(nil)
                        })
                    }
                }
            }
        }
    }
    
}
