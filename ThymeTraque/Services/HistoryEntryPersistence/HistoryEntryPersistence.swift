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
    
    init(jsonURL: URL) {
        self.jsonURL = jsonURL
    }
    
    func allEntries() -> Effect<Array<HistoryEntry>, Swift.Error> {
        return .future { [self] completion in
            do {
                let entries = try readEntries()
                completion(.success(entries))
            } catch {
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
                completion(.failure(error))
            }
        }
    }
    
    private func readEntries() throws -> Array<HistoryEntry> {
        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            // Yes, Apple suggests not to check if file exists and instead handle the error potentially
            // thrown by the operation. But for the clarity's sake checking for the json existance
            // seems a better trade-off, as opposed to parsing an NSError with obscure domain & code
            // out of the Swift Error.
            return []
        }
        
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
