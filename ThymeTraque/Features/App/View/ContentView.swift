//
//  ContentView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: AppStore
    let environment: AppEnvironment
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                TrackView(
                    store: store.trackStore,
                    environment: environment.trackEnvironment
                )
                HistoryView(
                    store: store.historyStore,
                    environment: environment.historyEnvironment
                )
            }
            .overlayConfirmationDialog(
                isPresented: viewStore.binding(
                    get: \.confirmationDialogState.isPresented,
                    send: { (_) -> AppAction in
                        preconditionFailure("This code is not supposed to be called. " +
                                            "Assumption is confirmation dialog doesn't manipulate its presentation.")
                    }
                ),
                title: viewStore.confirmationDialogState.title,
                message: viewStore.confirmationDialogState.message,
                textFieldBinding: viewStore.confirmationDialogState.inputText == nil ? nil : viewStore.binding(
                    get: { $0.confirmationDialogState.inputText ?? "" },
                    send: AppAction.confirmationDialogInputTextUpdated
                ),
                actions: [
                    .init(
                        title: viewStore.confirmationDialogState.acceptButtonTitle,
                        isCancelling: false,
                        closure: { viewStore.send(.dismissConfirmationDialog(accepted: true)) }
                    ),
                    .init(
                        title: viewStore.confirmationDialogState.cancelButtonTitle,
                        isCancelling: true,
                        closure: { viewStore.send(.dismissConfirmationDialog(accepted: false)) }
                    )
                ]
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: AppStoreProducer.preview.produce(),
            environment: .live
        )
    }
}
