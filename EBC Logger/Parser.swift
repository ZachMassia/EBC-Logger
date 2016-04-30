//
//  Parser.swift
//  EBC Logger
//
//  Created by Zachary Massia on 2016-04-25.
//  Copyright © 2016 Zachary Massia. All rights reserved.
//

import Foundation


/// A header and it's associated data.
struct SerialMessage {
    /// Defines the message type.
    let header: String
    
    /// The data associated with a given message.
    let data: [String]
}

///    Serial message error types
enum SerialMessageError: ErrorType {
    case InvalidPrefixOrSuffix
    case NoDataWithHeader
    case UnknownDataType
    case ExtraData
}

/// The predefined serial message protocol.
struct SerialProtocol {
    static let prefix:    Character = "!"
    static let suffix:    Character = "|"
    static let seperator: Character = ";"
    
    static func splitMessage(msg: String) -> [String] {
        return msg.componentsSeparatedByString(String(seperator))
    }
}



class Parser {
    /// The order the arduino is sending it's data packets.
    private var msgFormat = [String]()
    
    
    /**
        Parse the string received from the Arduino into a `SerialMessage`
     
        - Parameter message: The unparsed message string.
     
        - Returns: An initialized `SerialMessage` object.
    */
    private func parseRawSerialMessage(fromString message: String) throws -> SerialMessage {
        // Verify that the prefix and suffix are valid.
        let prefix = message[message.startIndex]
        let suffix = message[message.endIndex.advancedBy(-1)]
        
        guard prefix == SerialProtocol.prefix && suffix == SerialProtocol.suffix else {
            throw SerialMessageError.InvalidPrefixOrSuffix
        }
        
        // Remove the prefix and suffix.
        let trimmedMsg = message
            .stringByTrimmingWhitespaceAndNewline()
            .stringByTrimmingFirstAndLastChar()

        // Split the message on the seperator.
        let splitMsg = SerialProtocol.splitMessage(trimmedMsg)
        let data = splitMsg[1..<splitMsg.count]
        

        // Make sure at least one data item was received.
        if data.count < 1 {
            throw SerialMessageError.NoDataWithHeader
        }
        
        return SerialMessage(header: splitMsg[0], data: Array(data))
    }
    
    /**
        Register the log format message from the Arduino.
     
        The first line sent from the Arduino after a reboot defines the order of the sensor values 
        to be sent thereafter.
     
        - Parameter message: The unparsed log format string.
    */
    func registerLogFormat(message: String) throws {
        let serialMsg = try parseRawSerialMessage(fromString: message)
        msgFormat = serialMsg.data
    }

    /**
        Parse a sensor reading message from the Arduino.
     
        The sensor value is stored in a dictionary along with it's name as given in 
        the format string.
     
        - Parameter message: The unparsed sensor reading string.
     
        - Returns: A dictionary of sensor names to values.
    */
    func parseSensorReading(message: String) throws -> [String: String] {
        let serialMsg = try? parseRawSerialMessage(fromString: message)
        var readings = [String: String]()

        if let data = serialMsg?.data {
            guard data.count == msgFormat.count else {
                throw SerialMessageError.ExtraData
            }

            for (sensorID, value) in data.enumerate() {
                let sensorName = msgFormat[sensorID]
                readings[sensorName] = value
            }
        }
        return readings
    }
}


extension String {
    /**
        Returns a new string with the first and last characters removed.
    */
    func stringByTrimmingFirstAndLastChar() -> String {
        let newStartIndex = self.startIndex.advancedBy(1)
        let newEndIndex = self.endIndex.advancedBy(-1)

        return self.substringWithRange(newStartIndex..<newEndIndex)
    }
    
    /**
        Convenience function to trim whitespace and newline from string.
    */
    func stringByTrimmingWhitespaceAndNewline() -> String {
        return self.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
