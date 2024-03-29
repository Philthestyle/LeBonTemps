//
//  CocoaLumberjackCustomFormatter.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import CocoaLumberjack

class CocoaLumberjackCustomFormatter: NSObject, DDLogFormatter {
    
    let dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        var logLevel: String
        switch logMessage.flag {
        case DDLogFlag.error:
            logLevel = "E"
        case DDLogFlag.warning:
            logLevel = "W"
        case DDLogFlag.info:
            logLevel = "I"
        case DDLogFlag.debug:
            logLevel = "D"
        default:
            logLevel = "V"
        }
        let date = dateFormatter.string(from: logMessage.timestamp)
        let contextFormat: String
        if let functionName = logMessage.function {
            contextFormat = "\(logMessage.fileName)[\(logLevel):\(logMessage.line)]::\(functionName)"
        } else {
            contextFormat = "\(logMessage.fileName)[\(logLevel):\(logMessage.line)]"
        }
        return "\(date) \(contextFormat) \(logMessage.message)"
    }
}
