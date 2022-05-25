//
//  ConfirmationDialogView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct ConfirmationDialogView: ViewModifier {
    var store: ConfirmationDialogStore
    var environment: ConfirmationDialogEnvironment
    
    func body(content: Content) -> some View {
        WithViewStore(store) { viewStore in
            content
                .overlayConfirmationDialog(
                    isPresented: viewStore.binding(
                        get: \.isPresented,
                        send: { (_) -> ConfirmationDialogAction in
                            preconditionFailure("This code is not supposed to be called. " +
                                                "Assumption is confirmation dialog doesn't manipulate its presentation.")
                        }
                    ),
                    title: viewStore.title,
                    message: viewStore.message,
                    textFieldBinding: viewStore.inputText == nil ? nil : viewStore.binding(
                        get: { $0.inputText ?? "" },
                        send: ConfirmationDialogAction.updateInputText
                    ),
                    actions: [
                        .init(
                            title: viewStore.acceptButtonTitle,
                            isCancelling: false,
                            closure: { viewStore.send(.dismiss(accepted: true)) }
                        ),
                        .init(
                            title: viewStore.cancelButtonTitle,
                            isCancelling: true,
                            closure: { viewStore.send(.dismiss(accepted: false)) }
                        )
                    ]
                )
        }
    }
}

extension View {
    func confirmationDialog(store: ConfirmationDialogStore, environment: ConfirmationDialogEnvironment) -> some View {
        self.modifier(ConfirmationDialogView(store: store, environment: environment))
    }
}
