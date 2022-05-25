//
//  ConfirmationDialogStore.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import Foundation
import ComposableArchitecture

typealias ConfirmationDialogStore = Store<ConfirmationDialogState, ConfirmationDialogAction>


extension AppStore {
    var confirmationDialogStore: ConfirmationDialogStore {
        self.scope(
            state: \.confirmationDialogState,
            action: AppAction.confirmationDialog
        )
    }
}

extension ConfirmationDialogStore {
    static let live = AppStoreProducer.live.produce().confirmationDialogStore
    static let preview = AppStoreProducer.preview.produce().confirmationDialogStore
}
