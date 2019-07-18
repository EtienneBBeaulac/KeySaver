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
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tv: NSTextView!
    var textFinder: NSTextFinder!
    
    var apps: [Application] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        loadApps()
        tableView.selectRowIndexes(NSIndexSet(index: 0) as IndexSet, byExtendingSelection: false)
        loadLogs(forApp: apps[tableView.selectedRow].name)
//        loadLogs(forApp: (tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? AppCellView)?.appName.stringValue ?? nil)
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
            let name = app.localizedName
        {
            if name == "KeySaver" {
                loadApps()
                loadLogs(forApp: (tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: false) as! AppCellView).appName.stringValue)
            }
        }
    }
    
    func loadApps() {
//        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: Keylogger.dataDir.path)
            for element in contents {
                if let icon = NSImage.init(contentsOf: Keylogger.dataDir.appendingPathComponent(element).appendingPathComponent("appIcon.png")) {
                    apps.append(Application(name: element, icon: icon, data: ""))
                } else {
                    apps.append(Application(name: element, icon: #imageLiteral(resourceName: "start_icon"), data: ""))
                }
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadLogs(forApp appName: String?) {
        guard let appName = appName else { return }
        textFinder.noteClientStringWillChange()
        var fileContents: Data? = nil
        do {
            var completeText = ""
            let appPath = Keylogger.dataDir.appendingPathComponent(appName)
            let enumerator: FileManager.DirectoryEnumerator? = FileManager.default.enumerator(atPath: appPath.path)
            while let element = enumerator?.nextObject() as? String {
                if (element == ".DS_Store") { continue }
                if (element == LoggerCallback.appIconFileName) { continue }
                if (completeText != "") { completeText += "\n\n" }
                
                completeText += "=========== " + element + " ===========\n"

                fileContents = try RNCryptor.decrypt(data: (NSData.init(contentsOf: appPath.appendingPathComponent(element)) as Data), withPassword: LoggerCallback.PASSWORD)
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
//        scrollToBottom()
    }
    
    func scrollToBottom() {
        if let documentView = scrollView.documentView {
//            (documentView as! NSTextView).firstRect(forCharacterRange: <#T##NSRange#>, actualRange: <#T##NSRangePointer?#>)
            documentView.scroll(NSPoint(x: 0, y: documentView.bounds.size.height))
            
        }
    }
    
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return apps.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "AppCell"), owner: self) as! AppCellView
        let app = apps[row]
        
        cell.appIcon.image = app.icon
        cell.appName.stringValue = app.name
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        loadLogs(forApp: apps[row].name)
        return true
    }
}

