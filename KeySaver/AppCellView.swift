//
//  AppCellView.swift
//  KeySaver
//
//  Created by Etienne Beaulac on 7/17/19.
//  Copyright © 2019 Etienne Beaulac. All rights reserved.
//

import Cocoa

class AppCellView: NSTableCellView {
    
    @IBOutlet weak var appIcon: NSImageView!
    @IBOutlet weak var appName: NSTextField!
    
//    override var backgroundStyle: NSView.BackgroundStyle {
//        didSet {
//            switch backgroundStyle {
//            case .Dark:
//                appName.textColor = NSColor.whiteColor()
//            default:
//                appName.textColor = NSColor.blackColor()
//            }
//        }
//    }
}
