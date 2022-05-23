//
//  TrackReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias TrackReducer = Reducer<TrackState, TrackAction, TrackEnvironment>

class TrackReducerProducer: ReducerProducer {
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
                    return .none
                    
                case .activityDescriptionChanged(let updatedDescription):
                    state.activityDescription = updatedDescription
                    return .none
            }
        }
    }
    
    func produce() -> AppReducer {
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

