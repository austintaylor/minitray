//
//  AppDelegate.swift
//  MiniTray
//
//  Created by Austin Taylor on 7/31/14.
//  Copyright (c) 2014 Austin Taylor. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var _window: NSWindow
    init(window: NSWindow) {
        self._window = window
    }
    
    class func createWindow() {
        let application = NSApplication.sharedApplication()
        let window = NSWindow(contentRect: NSMakeRect(0, 0, 160, 24), styleMask: NSBorderlessWindowMask, backing: .Buffered, defer: false)
        window.level = Int(CGShieldingWindowLevel())
        window.collectionBehavior = .CanJoinAllSpaces
        window.backgroundColor = NSColor.clearColor()
        window.opaque = false
        window.makeKeyAndOrderFront(window)
        let applicationDelegate = AppDelegate(window: window)
        application.delegate = applicationDelegate
        application.run()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        let sf = NSScreen.mainScreen().visibleFrame
        let screens = NSScreen.screens()
        let wf = _window.frame
        _window.setFrameOrigin(NSPoint(
            x: sf.size.width - wf.size.width,
            y: 0
        ))
        let view = MiniTray(frame: NSMakeRect(0, 0, wf.width, wf.height), window: _window)
        _window.contentView = view
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
}

