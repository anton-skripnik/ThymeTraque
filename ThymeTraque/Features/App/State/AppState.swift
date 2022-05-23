//
//  AppState.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

struct AppState: Equatable {
    var historyState: HistoryState
    var trackState: TrackState
}

extension AppState {
    static let live = AppState(
        historyState: .live,
        trackState: .live
    )
    
    static let preivew = AppState(
        historyState: .preview,
        trackState: .preview
    )
}
