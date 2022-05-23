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
    let trackingSetDateProvider = SetDateProvider(date: .now)
    let trackingTimerTickInterval = TimeInterval(0.5)
    var store: TestStore<TrackState, TrackState, TrackAction, TrackAction, TrackEnvironment>!
    let scheduler = DispatchQueue.test
    
    override func setUp() {
        super.setUp()
        
        store = TestStore(
            initialState: TrackState(
                trackingStartDate: nil,
                activityTimeIntervalString: trackingActivityTimeIntervalString,
                activityDescription: trackingActivityDescription
            ),
            reducer: TrackReducerProducer().produce(),
            environment: TrackEnvironment(
                timeIntervalFormatter: TimeIntervalFormatter(),
                dateProvider: trackingSetDateProvider,
                timerTickInterval: trackingTimerTickInterval,
                scheduler: scheduler.eraseToAnyScheduler()
            )
        )
    }
    
    func test_trackReducer_onActivityDescriptionChanged_modifiesActivityDescription() {
        store.send(.activityDescriptionChanged("My updated activity")) {
            $0.activityDescription = "My updated activity"
        }
    }
    
    func test_trackReducer_onToggleTracking_trackingStartDateUpdatesTrackingTickActionPeriodicallyTriggersUntilAnotherToggleTrackingReceived() {
        store.send(.toggleTracking) { [self] in
            $0.trackingStartDate = trackingSetDateProvider.date
        }
        
        scheduler.advance(by: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: trackingTimerTickInterval))
        
        store.receive(.trackingTick)
        
        scheduler.advance(by: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: trackingTimerTickInterval))
        
        store.receive(.trackingTick)
        
        store.send(.toggleTracking) {
            $0.trackingStartDate = nil
        }
        
        scheduler.advance(by: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: trackingTimerTickInterval))
    }
}
