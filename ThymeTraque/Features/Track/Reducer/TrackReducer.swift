//
//  TrackReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias TrackReducer = Reducer<TrackState, TrackAction, TrackEnvironment>

class TrackReducerProducer: PullbackReducerProducer {
    typealias ReducerState = TrackState
    typealias ReducerAction = TrackAction
    typealias ReducerEnvironment = TrackEnvironment
    
    func produce() -> TrackReducer {
        return TrackReducer { state, action, environment in
            switch action { 
                case .toggleTracking:
                    if !state.isTracking {
                        return Self.handleStartTracking(state: &state, action: action, environment: environment)
                    } else {
                        return Self.handleEndTracking(state: &state, action: action, environment: environment)
                    }
                    
                case .trackingTick:
                    guard let startDate = state.trackingStartDate else {
                        environment.logger.c("Tracking tick action received but trackingStartDate is nil")
                        return .none
                    }
                    
                    let interval = environment.dateProvider.date.timeIntervalSince(startDate)
                    state.activityTimeIntervalString = environment.timeIntervalFormatter.string(from: interval)
                    state.activityTimeInterval = interval
                    
                    return .none
                    
                case .activityDescriptionChanged(let updatedDescription):
                    state.activityDescription = updatedDescription
                    return .none
                    
                case .activityDescriptionTextFieldFocused(let focused):
                    state.activityDescriptionTextFieldFocused = focused
                    return .none
                    
                case .persistActivity(description: _, timeInterval: _):
                    // The app-level reducer will handle it.
                    return .none
                    
                case .displayActivityPersistenceConfirmation(message: _, shouldIncludeTextInput: _):
                    // The app-level reducer will handle it.
                    return .none
                    
                case .confirmPersistingActivity(let shouldPersist, activityDescription: let fromConfirmationDialogDescription):
                    func resetState() {
                        state.trackingStartDate = nil
                        state.activityDescription = ""
                        state.activityTimeIntervalString = "00:00"
                    }
                    
                    guard shouldPersist else {
                        resetState()
                        return .none
                    }
                    
                    let description = { () -> String in
                        if !state.activityDescription.isEmpty {
                            return state.activityDescription
                        }
                        
                        if let activityDescription = fromConfirmationDialogDescription {
                            return activityDescription
                        }
                        
                        return "Untitled activity"
                    }()
                    
                    let timeInterval = state.activityTimeInterval
                    
                    resetState()
                    
                    return Effect(value: .persistActivity(description: description, timeInterval: timeInterval))
            }
        }
    }
    
    typealias PullbackReducerType = AppReducer
    func pullback() -> PullbackReducerType {
        return self.produce().pullback(
            state: \.trackState,
            action: /AppAction.track,
            environment: { $0.trackEnvironment }
        )
    }
    
    private enum TrackingTickTimerId {}
    
    private static func handleStartTracking(
        state: inout TrackState,
        action: TrackAction,
        environment: TrackEnvironment
    ) -> Effect<TrackAction, Never> {
        state.trackingStartDate = environment.dateProvider.date
        state.activityTimeInterval = 0.0
                    
        return Effect.timer(
            id: TrackingTickTimerId.self,
            every: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: environment.timerTickInterval),
            on: environment.scheduler
        ).map { _ in
            return TrackAction.trackingTick
        }
    }
    
    private static func handleEndTracking(
        state: inout TrackState,
        action: TrackAction,
        environment: TrackEnvironment
    ) -> Effect<TrackAction, Never> {
        var effectsToReturn: Array<Effect<TrackAction, Never>> = [
            .cancel(id: TrackingTickTimerId.self)
        ]
        
        if let startDate = state.trackingStartDate {
            let timeInterval = environment.dateProvider.date.timeIntervalSince(startDate)
            
            // We don't want users tracking entries with too small of a time interval
            if timeInterval < environment.timerTickInterval {
                return .none
            }
            
            let confirmationMessage: String
            let shouldRequestActivityDescription: Bool
            if state.activityDescription.isEmpty {
                shouldRequestActivityDescription = true
                confirmationMessage = "Provide a description for the activity and tap \"OK\". If you want to discard, tap \"Cancel\""
            } else {
                shouldRequestActivityDescription = false
                confirmationMessage = "Do you want to persist the activity? Tap \"Cancel\" to discard"
            }
            
            effectsToReturn.append(Effect(value: .displayActivityPersistenceConfirmation(
                message: confirmationMessage,
                shouldIncludeTextInput: shouldRequestActivityDescription
            )))
        } else {
            environment.logger.c("No start date at when tracking completes. This is not how it's supposed to be.")
        }
        
        // Remove focus from the description text field when user stops tracking.
        state.activityDescriptionTextFieldFocused = false
        
        return Effect.concatenate(effectsToReturn)
    }
}

