//
//  AppDelegate.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



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
    }


}

