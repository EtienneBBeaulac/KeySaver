//
//  ViewController.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tv: NSTextView!
    var textFinder: NSTextFinder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFinder = NSTextFinder()
        textFinder.client = tv as? NSTextFinderClient
        textFinder.findBarContainer = scrollView
        textFinder.incrementalSearchingShouldDimContentView = true
        textFinder.isIncrementalSearchingEnabled = true
        tv.usesFindBar = true
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
    
    func receiveSearch(query: String) {
        let text = tv.string as NSString
        let range = text.range(of: query)
        tv.scrollRangeToVisible(range)
        tv.showFindIndicator(for: range)
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
            }
        }
    }
    
    func loadLogs() {
        textFinder.noteClientStringWillChange()
        var fileContents: Data? = nil
        if (LoggerCallback.text.count > 0) {
            LoggerCallback.encrypt(text: LoggerCallback.text, toFile: Keylogger.filenameUrl)
            LoggerCallback.text = ""
        }
        do {
            fileContents = try RNCryptor.decrypt(data: NSData.init(contentsOf: Keylogger.keylogs.appendingPathComponent("logs")) as Data, withPassword: LoggerCallback.PASSWORD)
            if fileContents != nil {
                if let data = String(data: fileContents!, encoding: .utf8) {
                    tv.string = data
                } else {
                    tv.string = ""
                }
            }
        } catch {
            print("Problem loading logs:")
            print(error)
        }
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if let documentView = scrollView.documentView {
            documentView.scroll(NSPoint(x: 0, y: documentView.bounds.size.height))
            
        }
    }
    
}

