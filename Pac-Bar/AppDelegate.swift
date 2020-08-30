//
//  AppDelegate.swift
//  Pac-Bar
//
//  Created by Henry Franks on 21/11/16.
//  Copyright © 2016 Henry Franks. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return true
    }
}

