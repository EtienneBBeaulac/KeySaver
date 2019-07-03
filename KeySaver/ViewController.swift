//
//  ViewController.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var tv: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(activatedApp),
                                                          name: NSWorkspace.didActivateApplicationNotification,
                                                          object: nil)
        loadLogs()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc dynamic func activatedApp(notification: NSNotification)
    {
        if  let info = notification.userInfo,
            let app = info[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let name = app.localizedName,
            let _ = app.icon
        {
            if name == "KeySaver" {
                loadLogs()
                // TODO: Update textview from files
                // Use some kind of callback to alert ViewController
            }
        }
    }
    
    func loadLogs() {
        print("loadingLogs")
        let error: Error? = nil
        var fileContents: String? = nil
        do {
            print(Keylogger.keylogs.appendingPathComponent("logs"))
            fileContents = try String(contentsOf: Keylogger.keylogs.appendingPathComponent("logs") , encoding: .utf8)
        } catch {
            print("caught problem")
        }
        if fileContents != nil {
            // Yay!
            tv.string = fileContents!
        } else {
            // Boo!
            tv.string = ""
            if let error = error {
                print("Error loading \(Keylogger.keylogs.absoluteString). Underlying error: \(error)")
            }
        }
//        let data = FileManager.default.contents(atPath: Keylogger.keylogs.absoluteString);
        
    }

}

