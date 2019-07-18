//
//  LoggerCallback.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 5/2/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//  Inspired by Skrew Everything's GitHub for keylogger
//

import Foundation
import Cocoa

class LoggerCallback
{
    static let appIconFileName = "appIcon.png"
    static let PASSWORD = "this-is-the-PASSWORD-for-KeySaver1"
    static var CAPSLOCK = false
    static var SHIFT = false
    //    static var prev = ""
    static var command = false
    
//    static var text = ""
    
    static func encrypt(text: String, toFile file: URL, appIcon: NSImage? = Keylogger.activeApp.icon) {
        let appFolder = Keylogger.activeApp.name
        let path = Keylogger.dataDir.appendingPathComponent(appFolder)
        if !FileManager.default.fileExists(atPath: path.path)
        {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
                if let appIcon = appIcon {
                    if !appIcon.pngWrite(to: path.appendingPathComponent(appIconFileName)) {
                        print("could not save appicon for " + appFolder)
                    }
                }
            } catch {
                print("Can't create app directory!")
            }
        }
        if var fileContents = NSData.init(contentsOf: file) as Data? {
            print("file exists")
            if (!fileContents.isEmpty) {
                fileContents = try! RNCryptor.decrypt(data: fileContents as Data, withPassword: LoggerCallback.PASSWORD)
            }
            let newText = text.data(using: .utf8)!
            fileContents.append(newText)
            let ciphertext = RNCryptor.encrypt(data: fileContents as Data, withPassword: LoggerCallback.PASSWORD)
            try! FileManager.default.removeItem(atPath: file.path)
            if !FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil) {
                print("Can't Create File")
            }
            let fhs = FileHandle.init(forWritingAtPath: file.path)
            fhs?.seekToEndOfFile()
            fhs?.write(ciphertext)
        } else {
            print("file doesn't exist")
            let newText = text.data(using: .utf8)!
            let ciphertext = RNCryptor.encrypt(data: newText as Data, withPassword: LoggerCallback.PASSWORD)
            if !FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil) {
                print("Can't Create File")
            }
            let fhs = FileHandle.init(forWritingAtPath: file.path)
            fhs?.write(ciphertext)
        }
    }
    
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        
        let this = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let element: IOHIDElement = IOHIDValueGetElement(device);
        //        var test: Bool
        if IOHIDElementGetUsagePage(element) != 0x07 || Keylogger.activeApp.name == "KeySaver" {
            return
        }
        let code = IOHIDElementGetUsage(element);
        if (code < 4 || code > 231) {
            return
        }
        let pressed = IOHIDValueGetIntegerValue(device);
        
        Outside:if pressed == 1 { // keydown
            if code == 57 { // Capslock
                LoggerCallback.CAPSLOCK = !LoggerCallback.CAPSLOCK
                break Outside
            }
            if code >= 58 && code <= 83 || code == 41 || code == 42 {
                break Outside
            }
            if code == 225 || code == 229 { // Shift
                LoggerCallback.SHIFT = true
                break Outside
            }
            if code >= 224 && code <= 231 || command {
                command = true
                break Outside
            }
            if LoggerCallback.CAPSLOCK || LoggerCallback.SHIFT { // Show uppercase
                Keylogger.activeApp.data += this.keyMap[code]![1]
            } else { // Show lowercase
                Keylogger.activeApp.data += this.keyMap[code]![0]
            }
            if (Keylogger.activeApp.data.count == 10) {
                LoggerCallback.encrypt(text: Keylogger.activeApp.data, toFile: Keylogger.getDateFile(forApp: Keylogger.activeApp.name))
                Keylogger.activeApp.data = ""
            }
        } else { // keyup
            if code == 225 || code == 229 { // no more shift
                LoggerCallback.SHIFT = false
                break Outside
            }
            if code >= 224 && code <= 231 { // no more special keys
                command = false
            }
        }
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
