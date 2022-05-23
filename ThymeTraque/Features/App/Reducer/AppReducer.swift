//
//  AppReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

class AppReducerProducer: CompoundReducerProducer {
    typealias ReducerState = AppState
    typealias ReducerAction = AppAction
    typealias ReducerEnvironment = AppEnvironment
    
    let componentProducers: Array<AnyReducerProducer<AppState, AppAction, AppEnvironment>>
    
    init(_ componentProducers: Array<AnyReducerProducer<AppState, AppAction, AppEnvironment>>) {
        self.componentProducers = componentProducers
    }
}
