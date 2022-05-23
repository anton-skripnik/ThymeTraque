//
//  TrackEnvironment.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

struct TrackEnvironment {
    let timeIntervalFormatter: TimeIntervalFormatterProtocol
}

extension TrackEnvironment {
    static let preview = TrackEnvironment(
        timeIntervalFormatter: TimeIntervalFormatter()
    )
}
