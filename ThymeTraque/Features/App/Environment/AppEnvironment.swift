//
//  AppEnvironment.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import Foundation

struct AppEnvironment {
    let logger: LoggerProtocol
    
    let trackEnvironment: TrackEnvironment
}

extension AppEnvironment {
    static let live = AppEnvironment(
        logger: ConsoleLogger(formatter: TaggedDetailLoggerEntryFormatter(tag: "APP")),
        trackEnvironment: .live
    )
}
