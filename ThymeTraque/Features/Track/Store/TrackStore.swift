//
//  TrackStore.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias TrackStore = Store<TrackState, TrackAction>

extension AppStore {
    var trackStore: TrackStore {
        self.scope(
            state: \.trackState,
            action: AppAction.track
        )
    }
}

extension TrackStore {
    static let preview = AppStoreProducer.preview.produce().trackStore
}
