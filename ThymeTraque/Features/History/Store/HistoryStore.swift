//
//  HistoryStore.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias HistoryStore = Store<HistoryState, HistoryAction>

extension AppStore {
    var historyStore: HistoryStore {
        self.scope(
            state: \.historyState,
            action: AppAction.history
        )
    }
}

extension HistoryStore {
    static let live = AppStoreProducer.live.produce().historyStore
    static let preview = AppStoreProducer.preview.produce().historyStore
}
