//
//  SQLiteFileHistoryPersitence.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 24.05.2022.
//

import Foundation
import ComposableArchitecture
import SQLite3

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

extension SQLiteFileHistoryEntryPersistence /* Performance test helper */ {
    func populateDatabase(withRandomEntriesAt count: Int) throws {
        
        for i in 0..<count {
            let description = "Random entry description \(i)"
            let timeInterval = 0.33
            
            try prependEntry(description: description, timeInterval: timeInterval)
        }
        
    }
}
