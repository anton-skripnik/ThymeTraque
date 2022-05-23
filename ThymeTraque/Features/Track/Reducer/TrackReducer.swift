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
            return .none
        }
    }
    
    func produce() -> AppReducer {
        return self.produce().pullback(
            state: \.trackState,
            action: /AppAction.track,
            environment: { $0.trackEnvironment }
        )
    }
}

