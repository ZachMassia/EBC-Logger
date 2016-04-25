//
//  AppDelegate.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-04-20.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let arduino = ArduinoController()


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func connectToArduino(sender: AnyObject) {
        arduino.connect()
    }
    
    @IBAction func disconnectArduino(sender: AnyObject) {
        arduino.disconnect()
    }
}

