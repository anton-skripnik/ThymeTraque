//
//  ConfirmationDialogReducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import Foundation
import ComposableArchitecture

class ConfirmationDialogReducerProducer: ReducerProducer {
    func produce() -> AppReducer {
        return Reducer() { state, action, environment in
            switch action {
                case .history(_):
                    return .none
                    
                case .track(.displayActivityPersistenceConfirmation(message: let message, shouldIncludeTextInput: let shouldIncludeTextInput)):
                    return Effect(value: .displayConfirmationDialog(
                        title: nil,
                        message: message,
                        inputText: shouldIncludeTextInput ? "" : nil,
                        acceptButtonTitle: "OK",
                        cancelButtonTitle: "Cancel"
                    ))
                    
                case .track(_):
                    return .none
                    
                case .displayConfirmationDialog(
                    title: let title,
                    message: let message,
                    inputText: let inputText,
                    acceptButtonTitle: let acceptButtonTitle,
                    cancelButtonTitle: let cancelButtonTitle
                ):
                    state.confirmationDialogState.isPresented = true
                    state.confirmationDialogState.title = title
                    state.confirmationDialogState.message = message
                    state.confirmationDialogState.inputText = inputText
                    state.confirmationDialogState.acceptButtonTitle = acceptButtonTitle
                    state.confirmationDialogState.cancelButtonTitle = cancelButtonTitle
                    
                    return .none
                
                    
                case .dismissConfirmationDialog(accepted: let accepted):
                    state.confirmationDialogState.isPresented = false
                    return Effect(value: .track(.confirmPersistingActivity(
                        accepted,
                        activityDescription: state.confirmationDialogState.inputText
                    )))
                    
                case .confirmationDialogInputTextUpdated(let text):
                    state.confirmationDialogState.inputText = text
                    return .none
            }
        }
    }
}
