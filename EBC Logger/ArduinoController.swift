//
//  ArduinoController.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-04-21.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Foundation
import ORSSerial


class ArduinoController: NSObject, ORSSerialPortDelegate {
    let baudRate = 115200
    let serialPortManager = ORSSerialPortManager.sharedSerialPortManager()
    let parser = Parser()
    
    let formatDescriptor = ORSSerialPacketDescriptor(
        prefixString: "!log_format",
        suffixString: "|",
        maximumPacketLength: 250,
        userInfo: nil)
    
    let readingsDescriptor = ORSSerialPacketDescriptor(
        prefixString: "!sensor_readings",
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

    func connect() {
        self.serialPort = serialPortManager.availablePorts[0]
    }
    
    func disconnect() {
        if let port = self.serialPort {
            print("Closed serial port '\(port.name)'")
            port.close()
            self.serialPort = nil
        }
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
                print("Readings msg[\(packetData.length)]: '\(str)'")
                print(parser.parseSensorReading(str))
            default:
                break
            }
        }
    }
}
