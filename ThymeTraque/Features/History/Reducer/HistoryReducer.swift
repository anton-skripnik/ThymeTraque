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
            switch action {
                case .refresh:
                    let keptEntries = state.entries.elements
                    
                    return environment.persistence
                        .allEntries()
                        .receive(on: environment.scheduler)
                        .catchToEffect {
                            switch $0 {
                                case .success(let newEntries):
                                    return .receivedEntries(newEntries)
                                case .failure(let error):
                                    environment.logger.c("Error retrieving history entries \(error)")
                                    return .receivedEntries(keptEntries)
                            }
                        }
                    
                case .receivedEntries(let entries):
                    state.entries = IdentifiedArrayOf(uncheckedUniqueElements: entries, id: \.id)
                    return .none
            }
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
