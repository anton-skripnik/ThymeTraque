//
//  PersistHistoryEntryReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

class PersistHistoryEntryReducerProducer: ReducerProducer {
    typealias ReducerType = AppReducer
    
    func produce() -> ReducerType {
        return Reducer { state, action, environment in
            switch action {
                case .track(.persistActivity(description: let description, timeInterval: let timeInterval)):
                    return Effect(value: .history(.prepend(activityDescription: description, timeInterval: timeInterval)))
                case .track(_):
                    return .none
                case .history(_):
                    return .none
                case .displayConfirmationDialog(title: _, message: _, inputText: _, acceptButtonTitle: _, cancelButtonTitle: _):
                    return .none
                case .dismissConfirmationDialog(accepted: _):
                    return .none
                case .confirmationDialogInputTextUpdated(_):
                    return .none
            }
        }
    }
}
