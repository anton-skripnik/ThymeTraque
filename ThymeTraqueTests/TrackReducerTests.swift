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
    static let trackingStartDate = Date(timeIntervalSince1970: 12345)
    let trackingActivityTimeIntervalString = "12:34"
    let trackingActivityDescription = "My Activity"
    let trackingSetDateProvider = SetDateProvider(date: TrackReducerTests.trackingStartDate)
    let trackingTimerTickInterval = TimeInterval(1)
    var store: TestStore<TrackState, TrackState, TrackAction, TrackAction, TrackEnvironment>!
    let scheduler = DispatchQueue.test
    
    override func setUp() {
        super.setUp()
        
        store = TestStore(
            initialState: TrackState(
                trackingStartDate: nil,
                activityTimeIntervalString: trackingActivityTimeIntervalString,
                activityTimeInterval: 754.0,
                activityDescription: trackingActivityDescription,
                activityDescriptionTextFieldFocused: false
            ),
            reducer: TrackReducerProducer().produce(),
            environment: TrackEnvironment(
                timeIntervalFormatter: TimeIntervalFormatter(),
                dateProvider: trackingSetDateProvider,
                timerTickInterval: trackingTimerTickInterval,
                scheduler: scheduler.eraseToAnyScheduler(),
                logger: MuteLogger()
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
            $0.activityTimeInterval = 0
        }
        
        scheduler.advance(by: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: trackingTimerTickInterval))
        trackingSetDateProvider.date = trackingSetDateProvider.date.advanced(by: trackingTimerTickInterval)
        
        store.receive(.trackingTick) {
            $0.activityTimeIntervalString = "00:00"
            $0.activityTimeInterval = 0
        }
        
        scheduler.advance(by: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: trackingTimerTickInterval))
        trackingSetDateProvider.date = trackingSetDateProvider.date.advanced(by: trackingTimerTickInterval)
        
        store.receive(.trackingTick) { [self] in
            $0.activityTimeIntervalString = "00:01"
            $0.activityTimeInterval = trackingTimerTickInterval
        }
        
        store.send(.toggleTracking)
    }
    
    func test_trackReducer_onTrackingTick_activityTimeIntervalStringUpdates() {
        store.send(.toggleTracking) { [self] in
            $0.trackingStartDate = trackingSetDateProvider.date
            $0.activityTimeInterval = 0
        }
        
        let tickDate = trackingSetDateProvider.date.addingTimeInterval(10)
        trackingSetDateProvider.date = tickDate
        
        store.send(.trackingTick) {
            $0.activityTimeIntervalString = "00:10"
            $0.activityTimeInterval = 10
        }
        
        store.send(.toggleTracking)
    }
    
    func test_trackReducer_onToggleTrackingFlipsBackBeforeTrackingTick_stateDoesntChangeAndTrackingContinues() {
        store.send(.toggleTracking) { [self] in
            $0.trackingStartDate = trackingSetDateProvider.date
            $0.activityTimeInterval = 0
        }
        
        store.send(.toggleTracking)
        
        scheduler.advance()
    }
    
    func test_trackReducer_onToggleTrackingOffWhenDescriptionTextFieldWasFocused_removeFocusFromTextField() {
        let store = TestStore(
            initialState: TrackState(
                trackingStartDate: nil,
                activityTimeIntervalString: trackingActivityTimeIntervalString,
                activityTimeInterval: 754.0,
                activityDescription: trackingActivityDescription,
                activityDescriptionTextFieldFocused: true
            ),
            reducer: TrackReducerProducer().produce(),
            environment: TrackEnvironment(
                timeIntervalFormatter: TimeIntervalFormatter(),
                dateProvider: trackingSetDateProvider,
                timerTickInterval: trackingTimerTickInterval,
                scheduler: scheduler.eraseToAnyScheduler(),
                logger: MuteLogger()
            )
        )
        
        store.send(.toggleTracking) { [self] in
            $0.trackingStartDate = trackingSetDateProvider.date
            $0.activityTimeInterval = 0
        }
        
        scheduler.advance(by: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: trackingTimerTickInterval))
        trackingSetDateProvider.date = trackingSetDateProvider.date.advanced(by: trackingTimerTickInterval)
        
        store.receive(.trackingTick) {
            $0.activityTimeIntervalString = "00:00"
        }
        
        store.send(.toggleTracking) {
            $0.activityDescriptionTextFieldFocused = false
        }
        
        store.receive(.displayActivityPersistenceConfirmation(
            message: "This activity is going to be saved. Tap \"Cancel\" to discard",
            shouldIncludeTextInput: false
        ))
    }
}
