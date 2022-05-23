//
//  TrackEnvironment.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import CombineSchedulers

struct TrackEnvironment {
    let timeIntervalFormatter: TimeIntervalFormatterProtocol
    let dateProvider: DateProviderProtocol
    let timerTickInterval: TimeInterval
    let scheduler: AnySchedulerOf<DispatchQueue>
    let logger: LoggerProtocol
}

extension TrackEnvironment {
    static let live = TrackEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter(),
        dateProvider: NowDateProvider(),
        timerTickInterval: 1.0,
        scheduler: .main,
        logger: ConsoleLogger(formatter: TaggedDetailLoggerEntryFormatter(tag: "Track"))
    )
    
    static let preview = TrackEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter(),
        dateProvider: NowDateProvider(),
        timerTickInterval: 1.0,
        scheduler: .main,
        logger: ConsoleLogger(formatter: TaggedDetailLoggerEntryFormatter(tag: "Track"))
    )
}
