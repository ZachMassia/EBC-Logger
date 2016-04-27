//
//  Models.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-04-26.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Foundation
import RealmSwift

class Session: Object {
    /// Primary key; Randomly generated UUID.
    dynamic var sessionID = ""

    /// Non-unique, human-readable session identifier.
    dynamic var name = ""

    /// Detailed session description.
    dynamic var desc = ""

    /// The log's initial creation time, stored in string format.
    dynamic var creationTime = ""

    /// The session's log entries.
    let logs = List<Log>()

    override static func primaryKey() -> String? {
        return "sessionID"
    }
}

class Log: Object {
    /// Primary key; Randomly generated UUID.
    dynamic var logID = ""

    /// The timestamp given by the Arduino.
    dynamic var timestamp = 0

    /// The boost setpoint for the PID controller.
    dynamic var setpoint: Float = 0.0

    /// Calculated pressure from MAP sensor (PSIG).
    dynamic var mapReading: Float = 0.0

    /// Current duty cycle to solenoid.
    dynamic var dutyCycle = 0

    /// PID tuning variable.
    dynamic var kP: Float = 0.0

    /// PID tuning variable.
    dynamic var kI: Float = 0.0

    /// PID tuning variable.
    dynamic var kD: Float = 0.0

    /// Back reference to the session this log belongs to.
    var session: [Session] {
        return linkingObjects(Session.self, forProperty: "logs")
    }

    override static func primaryKey() -> String? {
        return "logID"
    }
}