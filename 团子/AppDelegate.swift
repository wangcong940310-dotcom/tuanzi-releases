//
//  AppDelegate.swift
//  团子
//
//  Created by 王聪 on 2026/4/14.
//

import Cocoa
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

