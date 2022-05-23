//
//  Logger.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import Foundation

enum LogLevel {
    case info
    case warn
    case crit
}

protocol LoggerProtocol {
    var formatter: LoggerEntryFormatter { get }
    
    func log(message: String)
}

extension LoggerProtocol {
    func i(_ message: String, date: Date = .now, fname: String = #function, file: String = #file, line: Int = #line) {
        log(message: formatter.format(level: .info, date: date, message: message, fname: fname, file: file, line: line))
    }
    
    func w(_ message: String, date: Date = .now, fname: String = #function, file: String = #file, line: Int = #line) {
        log(message: formatter.format(level: .warn, date: date, message: message, fname: fname, file: file, line: line))
    }
    
    func c(_ message: String, date: Date = .now, fname: String = #function, file: String = #file, line: Int = #line) {
        log(message: formatter.format(level: .crit, date: date, message: message, fname: fname, file: file, line: line))
    }
}

class ConsoleLogger: LoggerProtocol {
    let formatter: LoggerEntryFormatter
    
    init(formatter: LoggerEntryFormatter) {
        self.formatter = formatter
    }
    
    func log(message: String) {
        print(message)
    }
}

protocol LoggerEntryFormatter {
    func format(level: LogLevel, date: Date, message: String, fname: String, file: String, line: Int) -> String
}

class TaggedDetailLoggerEntryFormatter: LoggerEntryFormatter {
    let tag: String
    let dateFormatter: DateFormatter
    
    init(tag: String = "", dateFormatter: DateFormatter = .default) {
        self.tag = tag
        self.dateFormatter = dateFormatter
    }
    
    func format(level: LogLevel, date: Date, message: String, fname: String, file: String, line: Int) -> String {
        let levelMarker = { () -> String in
            switch level {
                case .info: return "INFO"
                case .warn: return "WARN"
                case .crit: return "CRIT"
            }
        }()
        
        let tagString = tag.isEmpty ? "" : "{\(tag)} "
        
        return (
            "<\(dateFormatter.string(from: date))> " +
            "[\(levelMarker)] " +
            "\(tagString) " +
            "(\(file.split(separator: "/").last!):\(line)@\(fname)) " +
            message
        )
    }
}
