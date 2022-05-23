//
//  HistoryReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias HistoryReducer = Reducer<HistoryState, HistoryAction, HistoryEnvironment>

class HistoryReducerProducer: PullbackReducerProducer {
    typealias ReducerType = HistoryReducer
    func produce() -> ReducerType {
        return ReducerType { state, action, environment in
            return .none
        }
    }
    
    typealias PullbackReducerType = AppReducer
    func pullback() -> PullbackReducerType {
        return self.produce().pullback(
            state: \.historyState,
            action: /AppAction.history,
            environment: { $0.historyEnvironment }
        )
    }
}
