//
//  WindowController.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    static let k = Keylogger()
    @IBOutlet weak var startBtn: NSToolbarItem!
    @IBOutlet weak var stopBtn: NSToolbarItem!
    @IBOutlet weak var searchField: NSToolbarItem!
//    let vc = ViewController.init(nibName: "ViewController", bundle: nil)
    
    override func windowDidLoad() {
        super.windowDidLoad()
        stopBtn.isEnabled = true
        startBtn.isEnabled = false
        WindowController.k.start()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidToggleLogger(_:)), name: .didToggleLogger, object: nil)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @objc func onDidToggleLogger(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            for (_, activated) in data {
                if activated {
                    startLogger()
                } else {
                    stopLogger()
                }
            }
        }
    }
    
    func startLogger() {
        WindowController.k.start()
        startBtn.isEnabled = false
        stopBtn.isEnabled = true
    }
    
    func stopLogger() {
        WindowController.k.stop()
        stopBtn.isEnabled = false
        startBtn.isEnabled = true
    }
    
    @IBAction func startClicked(_ sender: NSToolbarItem) {
        NotificationCenter.default.post(name: .didToggleLogger, object: self, userInfo: ["activated": true])
    }
    
    @IBAction func stopClicked(_ sender: NSToolbarItem) {
        NotificationCenter.default.post(name: .didToggleLogger, object: self, userInfo: ["activated": false])
    }
    
    @IBAction func searchEntered(_ sender: NSSearchField) {
        let searchQuery = sender.stringValue
        if searchQuery != "" {
            let vc = window!.contentViewController as! ViewController
            vc.receiveSearch(query: searchQuery)
        }
    }
    
    
}
