//
//  ViewController.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
//    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tv: NSTextView!
    var textFinder: NSTextFinder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        outlineView.dataSource = self
//        outlineView.delegate = self
        
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
    
    func forceWrite() {
        if (LoggerCallback.text.count > 0) {
            LoggerCallback.encrypt(text: LoggerCallback.text, toFile: Keylogger.getDateFile())
            LoggerCallback.text = ""
        }
    }
    
    func loadLogs() {
        textFinder.noteClientStringWillChange()
        forceWrite()
        var fileContents: Data? = nil
        do {
            var completeText = ""
            let enumerator: FileManager.DirectoryEnumerator? = FileManager.default.enumerator(atPath: Keylogger.keylogs.path)
            while let element = enumerator?.nextObject() as? String {
                if (element == ".DS_Store") { continue }
                if (completeText != "") { completeText += "\n\n" }
                
                completeText += "=========== " + element + " ===========\n"

                fileContents = try RNCryptor.decrypt(data: NSData.init(contentsOf: Keylogger.keylogs.appendingPathComponent(element)) as Data, withPassword: LoggerCallback.PASSWORD)
                if fileContents != nil {
                    if let data = String(data: fileContents!, encoding: .utf8) {
                        completeText += data
                    }
                }
            }
            tv.string = completeText
            
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

//extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        if let _ = item as? String {
//            return ("test", index) // return applications[index]
//        } else {
//            return 0
//        }
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        if let _ = item as? String {
//            return 1 // return applications.count
//        } else {
//            return 0
//        }
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        if item is String {
//            return true
//        }
//        return false
//    }
//
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
//            return nil
//        }
//
//        var text = ""
//
//        switch (columnIdentifier, item) {
//        case ("ApplicationColumn", let item as String):
//            ///// this will have to be changed to accomodate the application names
//            switch item {
//            case "name":
//                text = "Name"
//            case "age":
//                text = "Age"
//            case "birthPlace":
//                text = "Birth Place"
//            case "birthDate":
//                text = "Birth Date"
//            case "hobbies":
//                text = "Hobbies"
//            default:
//                break
//            }
//        case ("ApplicationColumn", _):
//            // Remember that we identified the hobby sub-rows differently
//            if let (key, item) = item as? (String, Int) {
//                text = "sub-test" // should be application files
//            }
//        default:
//            text = ""
//        }
//
//        let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewCell")
//        let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
//        cell.textField!.stringValue = text
//
//        return cell
//    }
//}
