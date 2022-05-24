//
//  HistoryEntryPersistenceTests.swift
//  ThymeTraqueTests
//
//  Created by Anton Skripnik on 23.05.2022.
//

import XCTest
import Combine

@testable import ThymeTraque

class HistoryEntryPersistencePerformanceTests: XCTestCase {
    static let numberOfRecords = 100_000
    
    fileprivate let helper = PerformanceTestHelper(numberOfRecords: HistoryEntryPersistencePerformanceTests.numberOfRecords)
    
    func test_jsonFileHistoryEntryPersistence_whenLargeAmountOfEntriesAreRead() throws {
        let jsonURL = helper.jsonURL
        
        try helper.prepareJSON()
        
        measure {
            let persistence = JSONFileHistoryEntryPersistence(jsonURL: jsonURL)
            
            let expectation = expectation(description: "Read all entries")
            
            let _ = persistence
                .allEntries()
                .sink(receiveCompletion: { _ in expectation.fulfill() }, receiveValue: { _ in })
            
            waitForExpectations(timeout: 20.0) { _ in self.stopMeasuring() }
        }
    }
    
    func test_jsonFileHistoryEntryPersistence_whenRecordIsPrepended() throws {
        let jsonURL = helper.jsonURL
        
        try helper.prepareJSON()
        
        measure {
            let persistence = JSONFileHistoryEntryPersistence(jsonURL: jsonURL)
            
            let expectation = expectation(description: "Insert new entry")
            
            let _ = persistence
                .prependNewEntry(with: "My entry description", and: 0.231)
                .sink(receiveCompletion: { _ in expectation.fulfill() }, receiveValue: { _ in })
            
            waitForExpectations(timeout: 20.0) { _ in self.stopMeasuring() }
        }
    }
    
    func test_sqliteFileHistoryEntryPersistence_whenLargeAmountOfEntriesAreRead() throws {
        try helper.prepareSQLiteStore()
        
        measure {
            let expectation = expectation(description: "Read all entries")
            
            let persistence = SQLiteFileHistoryEntryPersistence(fileURL: helper.sqliteURL)
            
            let _ = persistence
                .allEntries()
                .sink(receiveCompletion: { _ in expectation.fulfill() }, receiveValue: { _ in })
            
            waitForExpectations(timeout: 20.0) { _ in self.stopMeasuring() }
        }
    }
    
}

fileprivate struct PerformanceTestHelper {
    let numberOfRecords: Int
    
    init(numberOfRecords: Int) {
        self.numberOfRecords = numberOfRecords
    }
    
    let testDirectoryURL = try! FileManager.default.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
    var jsonURL: URL {
        testDirectoryURL.appendingPathComponent("very.big.entry.persistence.json")
    }
    
    var sqliteURL: URL {
        testDirectoryURL.appendingPathComponent("very.big.entry.persistence.sqlite")
    }
    
    func prepareJSON() throws {
        try? FileManager.default.removeItem(at: jsonURL)
            
        let entries = Array(0..<numberOfRecords)
            .map({ HistoryEntry(id: (numberOfRecords - $0), activityDescription: "Some description \(numberOfRecords - $0)", timeInterval: 0.3) })
        try! JSONEncoder().encode(entries).write(to: jsonURL)
    }
    
    func prepareSQLiteStore() throws {
        try? FileManager.default.removeItem(at: sqliteURL)
        
        let persistence = SQLiteFileHistoryEntryPersistence(fileURL: sqliteURL)
        
        try persistence.populateDatabase(withRandomEntriesAt: numberOfRecords)
    }
}
