//
//  ConfirmationDialogReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import Foundation
import ComposableArchitecture

typealias ConfirmationDialogReducer = Reducer<ConfirmationDialogState, ConfirmationDialogAction, ConfirmationDialogEnvironment>

class ConfirmationDialogReducerProducer: PullbackReducerProducer {
    func produce() -> ConfirmationDialogReducer {
        return Reducer() { state, action, environment in
            switch action {
                case .display(
                    title: let title,
                    message: let message,
                    inputText: let inputText,
                    acceptButtonTitle: let acceptButtonTitle,
                    cancelButtonTitle: let cancelButtonTitle
                ):
                    state.isPresented = true
                    state.title = title
                    state.message = message
                    state.inputText = inputText
                    state.acceptButtonTitle = acceptButtonTitle
                    state.cancelButtonTitle = cancelButtonTitle
                    
                    return .none
                
                    
                case .dismiss(accepted: _):
                    state.isPresented = false
                    state.title = nil
                    return .none
                    
                case .updateInputText(let text):
                    state.inputText = text
                    return .none
            }
        }
    }
    
    func pullback() -> AppReducer {
        produce().pullback(
            state: \.confirmationDialogState,
            action: /AppAction.confirmationDialog,
            environment: { $0.confirmationDialogEnvironment }
        )
    }
}
