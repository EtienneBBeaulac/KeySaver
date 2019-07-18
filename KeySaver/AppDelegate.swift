//
//  AppDelegate.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let didToggleLogger = Notification.Name("didToggleLogger")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mWindow: NSWindowController? = nil
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            var keepAlert = true
            while keepAlert {
                let answer = dialogOKCancel(question: "Turn on accessibility", text: "For KeySaver to work, select the KeySaver checkbox in Security & Privacy > Accessibility.")
                if (answer == .alertFirstButtonReturn) {
                    // Open system preferences
                    let prefPane = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
                    if let prefPane = prefPane {
                        NSWorkspace.shared.open(prefPane)
                    }
                    
                    keepAlert = false
                } else if (answer == .alertSecondButtonReturn) {
                    // Do nothing or close application
                    NSApplication.shared.terminate(self)
                } else {
                    // Open web page, probably github readme
                    let url = URL(string: "https://github.com/EtienneBBeaulac/KeySaver/blob/master/README.md")!
                    if NSWorkspace.shared.open(url) {
                        print("default browser was successfully opened")
                    }
                }
            }
        }
        statusItem.button?.title = "KS"
        statusItem.menu = NSMenu()
        statusItem.menu?.autoenablesItems = false
        addMenuItems()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidToggleLogger(_:)), name: .didToggleLogger, object: nil)
    }
    
    @objc func onDidToggleLogger(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            for (_, activated) in data {
                if activated {
                    statusItem.menu?.item(at: 0)?.isEnabled = false
                    statusItem.menu?.item(at: 1)?.isEnabled = true
                } else {
                    statusItem.menu?.item(at: 0)?.isEnabled = true
                    statusItem.menu?.item(at: 1)?.isEnabled = false
                }
            }
        }
    }
    
    func addMenuItems() {
        let startBtn = NSMenuItem(title: "", action: #selector(startLogger), keyEquivalent: "")
        startBtn.isEnabled = false
        startBtn.image = #imageLiteral(resourceName: "start_icon")
        statusItem.menu?.addItem(startBtn)
        
        let stopBtn = NSMenuItem(title: "", action: #selector(stopLogger), keyEquivalent: "")
        stopBtn.isEnabled = true
        stopBtn.image = #imageLiteral(resourceName: "stop_icon")
        statusItem.menu?.addItem(stopBtn)
    }
    
    @objc func startLogger(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .didToggleLogger, object: self, userInfo: ["activated": true])
    }
    
    @objc func stopLogger(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .didToggleLogger, object: self, userInfo: ["activated": false])
    }
    
    func mainWindowCached() -> NSWindowController? {
        if let window = NSApplication.shared.mainWindow?.windowController {
            self.mWindow = window
        }
        return self.mWindow
    }
    
    func dialogOKCancel(question: String, text: String) -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Turn On Accessibility")
        alert.addButton(withTitle: "Not Now")
        alert.addButton(withTitle: "Learn More")
        alert.buttons[2].setButtonType(.onOff)
        return alert.runModal()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
//        guard let vc = mainWindowCached()?.window!.contentViewController as? ViewController else {
//            return
//        }
//        vc.forceWrite()
    }
    
}

