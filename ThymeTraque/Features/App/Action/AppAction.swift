//
//  AppAction.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

enum AppAction: Equatable {
    case history(HistoryAction)
    case track(TrackAction)
    
    case displayConfirmationDialog(
        title: String?,
        message: String,
        inputText: String?,
        acceptButtonTitle: String,
        cancelButtonTitle: String
    )
    
    case dismissConfirmationDialog(accepted: Bool)
    
    case confirmationDialogInputTextUpdated(String)
}
