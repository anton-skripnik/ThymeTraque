//
//  TrackReducerTests.swift
//  ThymeTraqueTests
//
//  Created by Anton Skripnik on 23.05.2022.
//

import XCTest
import ComposableArchitecture
@testable import ThymeTraque

class TrackReducerTests: XCTestCase {
    let trackingStartDate = Date(timeIntervalSince1970: 12345)
    let trackingActivityTimeIntervalString = "12:34"
    let trackingActivityDescription = "My Activity"
    var store: TestStore<TrackState, TrackState, TrackAction, TrackAction, TrackEnvironment>!
    
    override func setUp() {
        super.setUp()
        
        store = TestStore(
            initialState: TrackState(
                trackingStartDate: trackingStartDate,
                activityTimeIntervalString: trackingActivityTimeIntervalString,
                activityDescription: trackingActivityDescription
            ),
            reducer: TrackReducerProducer().produce(),
            environment: TrackEnvironment(timeIntervalFormatter: TimeIntervalFormatter())
        )
    }
    
    func test_trackReducer_onActivityDescriptionChanged_modifiesActivityDescription() {
        store.send(.activityDescriptionChanged("My updated activity")) {
            $0.activityDescription = "My updated activity"
        }
    }
}
