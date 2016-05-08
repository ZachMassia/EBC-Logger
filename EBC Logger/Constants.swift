//
//  Constants.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-05-06.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Foundation

struct LoggerNotifications {
    static let sensorReading  = "sensorReadingNotification"
    static let sessionStarted = "sessionStartedNotification"
    static let sessionEnded   = "sessionEndedNotification"

    static let sessionNameKey = "sessionName"
    static let portNameKey    = "portName"
}