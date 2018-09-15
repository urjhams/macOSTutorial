//
//  AppDelegate.swift
//  EggTimer
//
//  Created by urjhams on 8/31/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var startTimerMenuItem: NSMenuItem!
    @IBOutlet weak var stopTimerMenuItem: NSMenuItem!
    @IBOutlet weak var resetTimerMenuItem: NSMenuItem!
    
    /// Set the menu items enable or disable
    /// - parameter start: menu item "start"
    /// - parameter stop: menu item "stop"
    /// - parameter reset: menu item "reset"
    func enableMenus(start: Bool, stop: Bool, reset:Bool) {
        startTimerMenuItem.isEnabled = start
        stopTimerMenuItem.isEnabled = stop
        resetTimerMenuItem.isEnabled = reset
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        enableMenus(start: true, stop: false, reset: false)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

