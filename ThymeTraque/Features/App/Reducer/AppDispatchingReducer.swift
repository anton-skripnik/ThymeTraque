//
//  AppDispatchingReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

class AppDispatchingReducerProducer: ReducerProducer {
    typealias ReducerType = AppReducer
    
    func produce() -> ReducerType {
        return Reducer { state, action, environment in
            switch action {
                case .track(.persistActivity(description: let description, timeInterval: let timeInterval)):
                    return Effect(value: .history(.prepend(activityDescription: description, timeInterval: timeInterval)))
                case .track(.displayActivityPersistenceConfirmation(message: let message, shouldIncludeTextInput: let includeTextInput)):
                    return Effect(
                        value: .confirmationDialog(
                            ConfirmationDialogAction.display(
                                title: nil,
                                message: message,
                                inputText: includeTextInput ? "" : nil,
                                acceptButtonTitle: "OK",
                                cancelButtonTitle: "Cancel"
                            )
                        )
                    )
                case .track(_):
                    return .none
                    
                case .history(_):
                    return .none
                    
                case .confirmationDialog(.dismiss(accepted: let accepted)):
                    let inputText = state.confirmationDialogState.inputText
                    return Effect(value: .track(.confirmPersistingActivity(accepted, activityDescription: inputText)))
                    
                case .confirmationDialog(_):
                    return .none
            }
        }
    }
}
