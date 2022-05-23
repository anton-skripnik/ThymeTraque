//
//  HistoryEnvironment.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import CombineSchedulers

struct HistoryEnvironment {
    let timeIntervalFormatter: TimeIntervalFormatterProtocol
    let logger: LoggerProtocol
    let persistence: HistoryEntryPersistenceProtocol
    let scheduler: AnySchedulerOf<DispatchQueue>
}


extension HistoryEnvironment {
    private static let persistence = JSONFileHistoryEntryPersistence(
        jsonURL: try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("history.entry.persistence.json")
    )
    
    private static let logger = ConsoleLogger(formatter: TaggedDetailLoggerEntryFormatter(tag: "History"))
    
    static let live = HistoryEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter(),
        logger: logger,
        persistence: persistence,
        scheduler: .main
    )
    static let preview = HistoryEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter(),
        logger: logger,
        persistence: persistence,
        scheduler: .main
    )
}
