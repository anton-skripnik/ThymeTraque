//
//  HistoryEntryPresistence.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

protocol HistoryEntryPersistenceProtocol {
    func allEntries() -> Effect<Array<HistoryEntry>, Swift.Error>
    func prependNewEntry(with activityDescription: String, and timeInterval: TimeInterval) -> Effect<Void, Swift.Error>
    func removeEntry(with id: HistoryEntry.ID) -> Effect<Void, Swift.Error>
}
