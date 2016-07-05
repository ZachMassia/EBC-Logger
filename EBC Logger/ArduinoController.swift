//
//  ArduinoController.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-04-21.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Foundation
import ORSSerial
import RealmSwift


class ArduinoController: NSObject, ORSSerialPortDelegate {
    let baudRate = 115200
    let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
    let parser = Parser()
    let realm = try! Realm()

    var currentSession: Session?
    
    let formatDescriptor = ORSSerialPacketDescriptor(
        prefixString: "!logFormat",
        suffixString: "|",
        maximumPacketLength: 250,
        userInfo: nil)
    
    let readingsDescriptor = ORSSerialPacketDescriptor(
        prefixString: "!sensorReadings",
        suffixString: "|",
        maximumPacketLength: 250,
        userInfo: nil)
    
    var serialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            if let port = serialPort {
                port.baudRate = baudRate
                port.delegate = self
                port.open()
            }
        }
    }

    deinit {
        serialPort = nil
    }

    func connectWithSession(name: String, description: String, portIndex: Int) {
        serialPort = serialPortManager.availablePorts[portIndex]
        currentSession = Session(value: ["name": name, "desc": description])
        currentSession?.sessionID = NSUUID.init().UUIDString
        try! realm.write {
            realm.add(currentSession!)
        }

        NSNotificationCenter.defaultCenter()
            .postNotificationName(LoggerNotifications.sessionStarted, object: nil,
                                  userInfo: [LoggerNotifications.sessionNameKey: name,
                                             LoggerNotifications.portNameKey: serialPort!.name])
    }
    
    func disconnect() {
        if let port = serialPort {
            print("Closed serial port '\(port.name)'")
            port.close()
            serialPort = nil
        }
        currentSession = nil

        NSNotificationCenter.defaultCenter()
            .postNotificationName(LoggerNotifications.sessionEnded, object: nil)
    }
    
    func serialPortWasOpened(serialPort: ORSSerialPort) {
        // Reset the Arduino.
        serialPort.DTR = false
        sleep(1)
        serialPort.DTR = true
        print("Arduino reset")

        // Register the packet descriptors.
        serialPort.startListeningForPacketsMatchingDescriptor(formatDescriptor)
        serialPort.startListeningForPacketsMatchingDescriptor(readingsDescriptor)
        
        print("Opened serial port '\(serialPort.name)'")
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
    
    func serialPort(serialPort: ORSSerialPort, didEncounterError error: NSError) {
        print("Serial port '\(serialPort)' encountered an error: '\(error)'")
    }

    func serialPort(serialPort: ORSSerialPort,
                    didReceivePacket packetData: NSData,
                    matchingDescriptor descriptor: ORSSerialPacketDescriptor) {
        let dataAsStr = String(data: packetData, encoding: NSASCIIStringEncoding)
        
        if let str = dataAsStr {
            switch descriptor {
            case formatDescriptor:
                do {
                    try parser.registerLogFormat(str)
                    print("Log format registered: [\(packetData.length)]: \(str)")
                } catch { print("Could not register log format") }
            case readingsDescriptor:
                do {
                    let log = Log()
                    log.logID = NSUUID.init().UUIDString
                    let r = try parser.parseSensorReading(str)

                    log.timestamp  = Int(r["timestamp"]!)!
                    log.setpoint   = Float(r["setpoint"]!)!
                    log.mapReading = Float(r["mapReading"]!)!
                    log.dutyCycle  = Float(r["dutyCycle"]!)!
                    log.kP         = Float(r["kP"]!)!
                    log.kI         = Float(r["kI"]!)!
                    log.kD         = Float(r["kD"]!)!

                    try realm.write {
                        currentSession!.logs.append(log)
                    }

                    NSNotificationCenter.defaultCenter()
                        .postNotificationName(LoggerNotifications.sensorReading, object: nil)
                } catch { print("Error parsing serial msg <\(str)>") }

            default:
                break
            }
        }
    }
}
