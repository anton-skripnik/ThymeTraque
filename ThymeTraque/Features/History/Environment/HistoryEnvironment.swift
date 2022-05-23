//
//  HistoryEnvironment.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

struct HistoryEnvironment {
    let timeIntervalFormatter: TimeIntervalFormatterProtocol
}


extension HistoryEnvironment {
    static let live = HistoryEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter()
    )
    static let preview = HistoryEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter()
    )
}
