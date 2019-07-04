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
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func startClicked(_ sender: NSToolbarItem) {
        print("start clicked")
        WindowController.k.start()
        sender.isEnabled = false
        stopBtn.isEnabled = true
    }
    
    @IBAction func stopClicked(_ sender: NSToolbarItem) {
        print("stop clicked")
        WindowController.k.stop()
        sender.isEnabled = false
        startBtn.isEnabled = true
    }
    
    @IBAction func searchEntered(_ sender: NSSearchField) {
        let searchQuery = sender.stringValue
        if searchQuery != "" {
            let vc = window!.contentViewController as! ViewController
            vc.receiveSearch(query: searchQuery)
//            vc.receiveSearch(query: searchQuery)
//            print("searched: " + searchQuery)
        }
    }
    
    
}
