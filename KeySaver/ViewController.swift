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
    var lastSelectedAppIndex = 0
    
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
                loadLogs(forApp: apps[lastSelectedAppIndex].name)
            }
        }
    }
    
    func loadApps() {
//        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        apps = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: Keylogger.dataDir.path)
            for element in contents {
                if (element == ".DS_Store") { continue }
                if let icon = NSImage.init(contentsOf: Keylogger.dataDir.appendingPathComponent(element).appendingPathComponent(LoggerCallback.appIconFileName)) {
                    apps.append(Application(name: element, icon: icon, data: ""))
                } else {
                    apps.append(Application(name: element, icon: #imageLiteral(resourceName: "start_icon"), data: ""))
                }
            }
            apps = apps.sorted(by: {$0.name < $1.name})
        } catch {
            print(error)
        }
        tableView.reloadData()
        tableView.selectRowIndexes(NSIndexSet(index: lastSelectedAppIndex) as IndexSet, byExtendingSelection: false)
    }
    
    func loadLogs(forApp appName: String?) {
        guard let appName = appName else { return }
        textFinder.noteClientStringWillChange()
        var fileContents: Data? = nil
        do {
            var files: [TextFile] = []
            let appPath = Keylogger.dataDir.appendingPathComponent(appName)
            let enumerator: FileManager.DirectoryEnumerator? = FileManager.default.enumerator(atPath: appPath.path)
            while let element = enumerator?.nextObject() as? String {
                if (element == ".DS_Store") { continue }
                if (element == LoggerCallback.appIconFileName) { continue }

                fileContents = try RNCryptor.decrypt(data: (NSData.init(contentsOf: appPath.appendingPathComponent(element)) as Data), withPassword: LoggerCallback.PASSWORD)
                if fileContents != nil {
                    if let data = String(data: fileContents!, encoding: .utf8) {
                        files.append(TextFile(name: element, contents: data))
                    }
                }
            }
            files = files.sorted(by: {$0.name > $1.name})
            tv.string = ""
            for file in files {
                if tv.string != "" { tv.string += "\n\n" }
                tv.string += "=========== " + file.name + " ===========\n"
                tv.string += file.contents
            }
            
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
        lastSelectedAppIndex = row
        return true
    }
}

