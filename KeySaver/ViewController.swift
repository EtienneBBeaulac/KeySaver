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
    
    func receiveSearch(query: String) {
//        print("received: \(query)")
        let text = tv.string
        print(text.range(of: query) ?? "not there")
//            let offset = text
//        let text = (tv.textStorage as NSAttributedString!).string
//        let offset = text.
//        int line = myTextView.getLayout().getLineForOffset(offset);
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
        var fileContents: String? = nil
        do {
            fileContents = try String(contentsOf: Keylogger.keylogs.appendingPathComponent("logs"), encoding: .utf8)
        } catch {
            print("caught problem")
        }
        if fileContents != nil {
            tv.string = fileContents!
        } else {
            tv.string = ""
        }
        scrollToBottom()
//        let data = FileManager.default.contents(atPath: Keylogger.keylogs.absoluteString);
        
    }
    
    func scrollToBottom() {
        if let documentView = scrollView.documentView {
            documentView.scroll(NSPoint(x: 0, y: documentView.bounds.size.height))
        }
    }

}

