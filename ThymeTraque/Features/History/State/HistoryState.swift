//
//  HistoryState.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import IdentifiedCollections

struct HistoryState: Equatable {
    var entries: IdentifiedArrayOf<HistoryEntry>
}

extension HistoryState {
    static let live = HistoryState(
        entries: IdentifiedArrayOf(
            uncheckedUniqueElements: [],
            id: \.id
        )
    )
    static let preview = HistoryState(
        entries: IdentifiedArrayOf(
            uncheckedUniqueElements: [
                .init(id: 1, activityDescription: "My activity 5", timeInterval: 0.33),
                .init(id: 2, activityDescription: "My activity 4", timeInterval: 1.33),
                .init(id: 3, activityDescription: "My activity 3", timeInterval: 2.33),
                .init(id: 4, activityDescription: "My activity 2", timeInterval: 3.33),
                .init(id: 5, activityDescription: "My activity 1", timeInterval: 4.33),
            ],
            id: \.id
        )
    )
}
