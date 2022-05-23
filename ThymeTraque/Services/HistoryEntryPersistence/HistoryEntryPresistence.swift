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

class JSONFileHistoryEntryPersistence: HistoryEntryPersistenceProtocol {
    let jsonURL: URL
    let logger: LoggerProtocol
    
    init(jsonURL: URL, logger: LoggerProtocol) {
        self.jsonURL = jsonURL
        self.logger = logger
    }
    
    func allEntries() -> Effect<Array<HistoryEntry>, Swift.Error> {
        return .future { [self] completion in
            do {
                let entries = try readEntries()
                completion(.success(entries))
            } catch {
                logger.c("Error reading history entries \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func prependNewEntry(with activityDescription: String, and timeInterval: TimeInterval) -> Effect<Void, Swift.Error> {
        return .future { [self] completion in
            do {
                var entries = try readEntries()
                
                let newEntry = HistoryEntry(
                    id: getNextAvailableId(from: entries),
                    activityDescription: activityDescription,
                    timeInterval: timeInterval
                )
                
                entries.insert(newEntry, at: 0)
                
                try write(entries: entries)
                
                completion(.success(()))
            } catch {
                logger.c("Error preprending a new entry \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func removeEntry(with id: HistoryEntry.ID) -> Effect<Void, Swift.Error> {
        enum RemoveError: Swift.Error {
            case entryWithIDNotFound
        }
        
        return .future { [self] completion in
            do {
                var entries = try readEntries()
                
                guard let idx = entries.firstIndex(where: { $0.id == id }) else {
                    throw RemoveError.entryWithIDNotFound
                }
                
                entries.remove(at: idx)
                
                try write(entries: entries)
                
                completion(.success(()))
            } catch {
                logger.c("Error removing an entry with id \(id). Error \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private func readEntries() throws -> Array<HistoryEntry> {
        let jsonData = try Data(contentsOf: jsonURL)
        return try JSONDecoder().decode(Array<HistoryEntry>.self, from: jsonData)
    }
    
    private func write(entries: Array<HistoryEntry>) throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: jsonURL)
    }
    
    // Kinda silly logic. In a real db, it should be issued by the database engine.
    private func getNextAvailableId(from entries: Array<HistoryEntry>) -> HistoryEntry.ID {
        return entries.reduce(0, { curMaxId, currentEntry in max(curMaxId, currentEntry.id) }) + 1
    }
}
