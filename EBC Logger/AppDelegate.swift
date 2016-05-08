//
//  AppDelegate.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-04-20.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Cocoa
import RealmSwift


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var boostBar: NSLevelIndicator!
    @IBOutlet weak var sessionNameField: NSTextField!
    @IBOutlet weak var sessionDescField: NSTextField!

    @IBOutlet weak var portLabel: NSTextField!
    @IBOutlet weak var sessionLabel: NSTextField!

    let realm = try! Realm()

    let arduino = ArduinoController()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(AppDelegate.didReceiveSensorReadingNotification),
                         name: LoggerNotifications.sensorReading, object: nil)

        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(AppDelegate.newSessionDidStart),
                         name: LoggerNotifications.sessionStarted, object: nil)

        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(AppDelegate.sessionDidEnd),
                         name: LoggerNotifications.sessionEnded, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func connectToArduino(sender: AnyObject) {
        arduino.connectWithSession(sessionNameField.stringValue, description: sessionDescField.stringValue)
    }
    
    @IBAction func disconnectArduino(sender: AnyObject) {
        arduino.disconnect()
    }

    func didReceiveSensorReadingNotification(notification: NSNotification) {
        boostBar.floatValue = (arduino.currentSession?.logs.last?.mapReading)!
    }

    func newSessionDidStart(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, String> {
            sessionLabel.stringValue = info[LoggerNotifications.sessionNameKey]!
            portLabel.stringValue = info[LoggerNotifications.portNameKey]!
        }
        sessionNameField.stringValue = ""
        sessionDescField.stringValue = ""
    }

    func sessionDidEnd(notification: NSNotification) {
        sessionLabel.stringValue = ""
        portLabel.stringValue = ""
    }
}

