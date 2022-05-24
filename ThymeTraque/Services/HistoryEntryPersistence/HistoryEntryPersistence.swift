//
//  HistoryEntryPresistence.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture
import SQLite3

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

class SQLiteFileHistoryEntryPersistence: HistoryEntryPersistenceProtocol {
    let fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func allEntries() -> Effect<Array<HistoryEntry>, Swift.Error> {
        return .future { [self] completion in
            do {
                let entries = try getAllEntries()
                completion(.success(entries))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func prependNewEntry(with activityDescription: String, and timeInterval: TimeInterval) -> Effect<Void, Swift.Error> {
        return .future { [self] completion in
            do {
                try prependEntry(description: activityDescription, timeInterval: timeInterval)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func removeEntry(with id: HistoryEntry.ID) -> Effect<Void, Swift.Error> {
        return .future { [self] completion in
            do {
                try remove(entryWith: id)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    enum Error: Swift.Error {
        case cantOpen(Int32)
        case connectionMissing
        case sqlError(Int32)
        case badStatement
        case badColumn(String)
    }
    
    deinit {
        if let connection = sqlConnection {
            sqlite3_close_v2(connection)
            sqlConnection = nil
        }
    }
    
    private var sqlConnection: OpaquePointer?
    private var getAllEntriesStatement: OpaquePointer?
    private var prependEntryStatement: OpaquePointer?
    private var removeEntryStatement: OpaquePointer?
    
    private func ensureConnected() throws -> OpaquePointer {
        if let connection = sqlConnection {
            return connection
        }
        
        try ensure(sqlite3_open_v2(
            fileURL.path.cString(using: .utf8),
            &sqlConnection,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            nil
        ), or: Error.cantOpen)
        
        if sqlConnection == nil {
            throw Error.connectionMissing
        }
        
        let createEntriesTableSQL = """
            CREATE TABLE IF NOT EXISTS HistoryEntry (
                ID INTEGER PRIMARY KEY ASC,
                Description TEXT NOT NULL,
                TimeInterval FLOAT NOT NULL
            )
        """
        try ensure(sqlite3_exec(
            sqlConnection,
            createEntriesTableSQL.cString(using: .utf8),
            nil,
            nil,
            nil
        ), or: Error.sqlError)
        
        return sqlConnection!
    }
    
    private func ensure(_ result: Int32, is expectedValue: Int32 = SQLITE_OK, or thrownError: (Int32) -> Swift.Error) throws {
        if result != expectedValue {
            throw thrownError(result)
        }
    }
    
    private func getAllEntries() throws -> Array<HistoryEntry> {
        let connection = try ensureConnected()
     
        let statement = try { () throws -> OpaquePointer? in
            if self.getAllEntriesStatement != nil {
                return self.getAllEntriesStatement
            }
            
            let selectAllSQL = """
                SELECT * FROM HistoryEntry ORDER BY ID DESC;
            """
            
            try ensure(sqlite3_prepare_v3(
                connection,
                selectAllSQL.cString(using: .utf8),
                -1,
                0,
                &self.getAllEntriesStatement,
                nil
            ), or: Error.sqlError)
            
            if self.getAllEntriesStatement == nil {
                throw Error.badStatement
            }
            
            return self.getAllEntriesStatement!
        }()
        
        var result: Array<HistoryEntry> = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            guard let description = sqlite3_column_text(statement, 1).map({ String(cString: $0) }) else {
                throw Error.badColumn("Description")
            }
            let timeInterval = sqlite3_column_double(statement, 2)
            
            result.append(HistoryEntry(id: Int(id), activityDescription: description, timeInterval: timeInterval))
        }
        
        try ensure(sqlite3_reset(statement), or: Error.sqlError)
        
        return result
    }
    
    private func prependEntry(description: String, timeInterval: TimeInterval) throws {
        let connection = try ensureConnected()
        
        let statement = try { () -> OpaquePointer? in
            if self.prependEntryStatement != nil {
                return self.prependEntryStatement
            }
            
            let insertSQL = """
                INSERT INTO HistoryEntry(
                    Description,
                    TimeInterval
                ) VALUES (
                    ?,
                    ?
                )
            """
            
            try ensure(sqlite3_prepare_v3(
                connection,
                insertSQL.cString(using: .utf8),
                -1,
                0,
                &self.prependEntryStatement,
                nil
            ), or: Error.sqlError)
            
            if self.prependEntryStatement == nil {
                throw Error.badStatement
            }
            
            return self.prependEntryStatement
        }()
        
        try ensure(sqlite3_bind_text(
            statement,
            1,
            description.cString(using: .utf8),
            -1,
            nil
        ), or: Error.sqlError)
        
        try ensure(sqlite3_bind_double(
            statement,
            2,
            timeInterval
        ), or: Error.sqlError)
        
        try ensure(sqlite3_step(statement), is: SQLITE_DONE, or: Error.sqlError)
        
        try ensure(sqlite3_reset(statement), or: Error.sqlError)
    }
    
    private func remove(entryWith id: HistoryEntry.ID) throws {
        let connection = try ensureConnected()
        
        let statement = try { () -> OpaquePointer? in
            if self.removeEntryStatement != nil {
                return self.removeEntryStatement
            }
            
            let insertSQL = """
                DELETE FROM HistoryEntry WHERE ID = ?
            """
            
            try ensure(sqlite3_prepare_v3(
                connection,
                insertSQL.cString(using: .utf8),
                -1,
                0,
                &self.removeEntryStatement,
                nil
            ), or: Error.sqlError)
            
            if self.removeEntryStatement == nil {
                throw Error.badStatement
            }
            
            return self.removeEntryStatement
        }()
        
        try ensure(sqlite3_bind_int(statement, 1, Int32(id)), or: Error.sqlError)
        
        try ensure(sqlite3_step(statement), is: SQLITE_DONE, or: Error.sqlError)
        
        try ensure(sqlite3_reset(statement), or: Error.sqlError)
    }
}
