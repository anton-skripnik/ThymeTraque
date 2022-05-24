//
//  HistoryEntryPersistenceTests.swift
//  ThymeTraqueTests
//
//  Created by Anton Skripnik on 23.05.2022.
//

import XCTest
import Combine

@testable import ThymeTraque

class HistoryEntryPersistenceTests: XCTestCase {
    
    func test_jsonFileHistoryEntryPersistence_whenLargeAmountOfEntriesAreRead() throws {
        let numberOfRecords = 100000
        
        let jsonURL = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("very.big.entry.persistence.json")
        
        func prepareJSON () {
            try? FileManager.default.removeItem(at: jsonURL)
            
            let entries = Array(0..<numberOfRecords)
                .map({ HistoryEntry(id: (numberOfRecords - $0), activityDescription: "Some description \(numberOfRecords - $0)", timeInterval: 0.3) })
            try! JSONEncoder().encode(entries).write(to: jsonURL)
        }
        
        prepareJSON()
        
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
        let numberOfRecords = 100000
        
        let jsonURL = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("very.big.entry.persistence.json")
        
        func prepareJSON () {
            try? FileManager.default.removeItem(at: jsonURL)
            
            let entries = Array(0..<numberOfRecords)
                .map({ HistoryEntry(id: (numberOfRecords - $0), activityDescription: "Some description \(numberOfRecords - $0)", timeInterval: 0.3) })
            try! JSONEncoder().encode(entries).write(to: jsonURL)
        }
        
        prepareJSON()
        
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
        let numberOfRecords = 100000
        
        let fileURL = try! FileManager.default
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("very.big.entry.persistence.sqlite")
        
        let persistence = SQLiteFileHistoryEntryPersistence(fileURL: fileURL)
        
        func prepareSQLiteStore () {
            let exp = expectation(description: "Prepare SQL")
            
            var cancellables: Array<AnyCancellable> = []
            
            try? FileManager.default.removeItem(at: fileURL)
            
            for i in (0..<numberOfRecords) {
                persistence
                    .prependNewEntry(with: "Some description \(numberOfRecords - i)", and: 0.3)
                    .sink(receiveCompletion: { _ in
                        if i >= numberOfRecords-1 {
                            exp.fulfill()
                        }
                    }, receiveValue: { _ in })
                    .store(in: &cancellables)
            }
            
            waitForExpectations(timeout: 30.0) { _ in }
        }
        
        prepareSQLiteStore()
        
        measure {
            let expectation = expectation(description: "Read all entries")
            
            let _ = persistence
                .allEntries()
                .sink(receiveCompletion: { _ in expectation.fulfill() }, receiveValue: { _ in })
            
            waitForExpectations(timeout: 20.0) { _ in self.stopMeasuring() }
        }
    }
    
}

