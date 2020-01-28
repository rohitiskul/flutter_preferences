//
//  SwiftFlutterPreferencesStandardWriter.swift
//
//  Created by Rohit Kulkarni on 1/27/20.
//

import Foundation
import Flutter

let DATE_TIME:UInt8 = 128

class PreferencesWriter : FlutterStandardWriter {
    
    override func writeValue(_ value: Any) {
        if value is NSDate {
            self.writeByte(DATE_TIME)
            let date:NSDate = value as! NSDate
            let timeInterval:TimeInterval = date.timeIntervalSince1970
            var ms = timeInterval * 1000.0
            self.writeBytes(&ms, length: 8)
        } else {
            super.writeValue(value)
        }
    }
}

class PreferencesReader : FlutterStandardReader {
    override func readValue(ofType type: UInt8) -> Any? {
        if (type == DATE_TIME) {
            var value: Double = 0
            self.readBytes(&value, length: 8)
            let time = TimeInterval(NSNumber(value: value).doubleValue / 1000.0)
            return Date(timeIntervalSince1970: time)
        } else {
           return super.readValue(ofType: type)
        }
    }
}

class PreferencesReaderWriter : FlutterStandardReaderWriter {
    override func writer(with data: NSMutableData) -> FlutterStandardWriter {
        return PreferencesWriter(data: data)
    }
    
    override func reader(with data: Data) -> FlutterStandardReader {
        return PreferencesReader(data: data)
    }
}
