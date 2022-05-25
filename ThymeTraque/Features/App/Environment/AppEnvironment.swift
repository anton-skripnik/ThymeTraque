//
//  AppEnvironment.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import Foundation

struct AppEnvironment {
    let logger: LoggerProtocol
    
    let historyEnvironment: HistoryEnvironment
    let trackEnvironment: TrackEnvironment
    
    let confirmationDialogEnvironment: ConfirmationDialogEnvironment
}

extension AppEnvironment {
    static let live = AppEnvironment(
        logger: ConsoleLogger(formatter: TaggedDetailLoggerEntryFormatter(tag: "APP")),
        historyEnvironment: .live,
        trackEnvironment: .live,
        confirmationDialogEnvironment: .live
    )
    
    static let preview = AppEnvironment(
        logger: ConsoleLogger(formatter: TaggedDetailLoggerEntryFormatter(tag: "APP")),
        historyEnvironment: .preview,
        trackEnvironment: .preview,
        confirmationDialogEnvironment: .preview
    )
}
