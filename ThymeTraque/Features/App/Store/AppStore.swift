//
//  AppStore.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

typealias AppStore = Store<AppState, AppAction>

protocol AppStoreProducerProtocol {
    func produce() -> AppStore
}

class AppStoreProducer: AppStoreProducerProtocol {
    let initialState: AppState
    let reducer: AppReducer
    let environment: AppEnvironment
    
    init(initialState: AppState, reducer: AppReducer, environment: AppEnvironment) {
        self.initialState = initialState
        self.reducer = reducer
        self.environment = environment
    }
    
    func produce() -> AppStore {
        return Store(
            initialState: initialState,
            reducer: reducer,
            environment: environment
        )
    }
}

extension AppStoreProducer {
    static let live = AppStoreProducer(
        initialState: .live,
        reducer: AppReducerProducer([
            TrackReducerProducer().erasePullbackToAnyProducer(),
            HistoryReducerProducer().erasePullbackToAnyProducer(),
            PersistHistoryEntryReducerProducer().eraseToAnyProducer(),
            ConfirmationDialogReducerProducer().eraseToAnyProducer(),
        ]).produce(),
        environment: .live
    )
    
    static let preview = AppStoreProducer(
        initialState: .preivew,
        reducer: AppReducerProducer([]).produce(),
        environment: .live
    )
}
