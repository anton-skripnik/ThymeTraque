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
                    
                    return .none
                    
                case .activityDescriptionChanged(let updatedDescription):
                    state.activityDescription = updatedDescription
                    return .none
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
    
    private static func handleStartTracking(state: inout TrackState, action: TrackAction, environment: TrackEnvironment) -> Effect<TrackAction, Never> {
        state.trackingStartDate = environment.dateProvider.date
                    
        return Effect.timer(
            id: TrackingTickTimerId.self,
            every: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: environment.timerTickInterval),
            on: environment.scheduler
        ).map { _ in
            return TrackAction.trackingTick
        }
    }
    
    private static func handleEndTracking(state: inout TrackState, action: TrackAction, environment: TrackEnvironment) -> Effect<TrackAction, Never> {
        state.trackingStartDate = nil
        
        return Effect.cancel(id: TrackingTickTimerId.self)
    }
}

