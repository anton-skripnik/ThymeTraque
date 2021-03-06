//
//  HistoryReducerTests.swift
//  ThymeTraqueTests
//
//  Created by Anton Skripnik on 23.05.2022.
//

import XCTest
import ComposableArchitecture

@testable import ThymeTraque

class HistoryReducerTests: XCTestCase {
    var persistence: FakeHistoryEntryPersistence!
    var environment: HistoryEnvironment!
    let scheduler = DispatchQueue.test
    var store: TestStore<HistoryState, HistoryState, HistoryAction, HistoryAction, HistoryEnvironment>!
    
    let entries: Array<HistoryEntry> = [
        HistoryEntry(id: 5, activityDescription: "activity 5", timeInterval: 0.33),
        HistoryEntry(id: 4, activityDescription: "activity 4", timeInterval: 1.33),
        HistoryEntry(id: 3, activityDescription: "activity 3", timeInterval: 2.33),
        HistoryEntry(id: 2, activityDescription: "activity 2", timeInterval: 3.33),
        HistoryEntry(id: 1, activityDescription: "activity 1", timeInterval: 4.33),
    ]
    
    override func setUp() {
        super.setUp()
        
        self.persistence = FakeHistoryEntryPersistence()
        self.persistence.entries = entries
        
        self.environment = HistoryEnvironment(
            timeIntervalFormatter: TimeIntervalFormatter(),
            logger: MuteLogger(),
            persistence: persistence,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        self.store = TestStore(
            initialState: HistoryState(entries: .init()),
            reducer: HistoryReducerProducer().produce(),
            environment: self.environment
        )
    }
    
    func test_historyReducer_onRefresh_retrievesEntriesFromPersistenceAndTriggersReceivedEntriesActionWhichUpdatesEntriesInState() {
        store.send(.refresh)
        
        scheduler.advance()
        
        store.receive(.receivedEntries(entries)) { [self] in
            $0.entries = IdentifiedArrayOf(uncheckedUniqueElements: entries, id: \.id)
        }
        
        XCTAssertTrue(persistence.allEntriesCalled)
    }
    
    func test_historyReducer_onPrependEntry_asksPersistenceToPrependAndInitiatesRefreshAction() {
        persistence.prependedNewEntryID = 6
        
        store.send(.prepend(activityDescription: "Prepended activity", timeInterval: 0.1))
        
        scheduler.advance()
        
        store.receive(.refresh)
        
        store.receive(.receivedEntries(persistence.entries)) { [self] in
            $0.entries = IdentifiedArrayOf(uniqueElements: persistence.entries, id: \.id)
        }
        
        XCTAssertTrue(persistence.prependNewEntryCalled)
        XCTAssertEqual(persistence.entries.first!.id, persistence.prependedNewEntryID)
        XCTAssertEqual(persistence.entries.first!.activityDescription, "Prepended activity")
        XCTAssertEqual(persistence.entries.first!.timeInterval, 0.1)
    }
    
    func test_historyReducer_onRemoveEntry_asksPersistenceToRemoveTheEntryAndInitiatesRefreshAction() {
        let idToRemove = 3
        
        XCTAssertTrue(persistence.entries.contains(where: { $0.id == idToRemove }))
        
        store.send(.removeEntry(id: idToRemove))
        
        scheduler.advance()
        
        store.receive(.refresh)
        store.receive(.receivedEntries(persistence.entries)) { [self] in
            $0.entries = IdentifiedArrayOf(uniqueElements: persistence.entries, id: \.id)
        }
        
        XCTAssertTrue(persistence.removeEntryCalled)
        XCTAssertFalse(persistence.entries.contains(where: { $0.id == idToRemove }))
    }
}

class FakeHistoryEntryPersistence: HistoryEntryPersistenceProtocol {
    var entries: Array<HistoryEntry> = []
    var allEntriesCalled = false
    
    var prependedNewEntryID: Int = 1234
    var prependNewEntryCalled = false
    
    var removeEntryCalled = false
    
    func allEntries() -> Effect<Array<HistoryEntry>, Error> {
        allEntriesCalled = true
        
        return .init(value: entries)
    }
    
    func prependNewEntry(with activityDescription: String, and timeInterval: TimeInterval) -> Effect<Void, Error> {
        prependNewEntryCalled = true
        
        entries.insert(HistoryEntry(id: prependedNewEntryID, activityDescription: activityDescription, timeInterval: timeInterval), at: 0)
        
        return .init(value: ())
    }
    
    func removeEntry(with id: HistoryEntry.ID) -> Effect<Void, Error> {
        removeEntryCalled = true
        
        guard let idx = entries.firstIndex(where: { $0.id == id }) else {
            return .init(value: ())
        }
        
        entries.remove(at: idx)
        
        return .init(value: ())
    }
    
    
}
