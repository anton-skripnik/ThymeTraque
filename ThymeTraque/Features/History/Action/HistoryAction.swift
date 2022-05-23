//
//  HistoryAction.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

enum HistoryAction: Equatable {
    case refresh
    case receivedEntries(Array<HistoryEntry>)
    case prepend(activityDescription: String, timeInterval: TimeInterval)
    case removeEntry(id: HistoryEntry.ID)
}
