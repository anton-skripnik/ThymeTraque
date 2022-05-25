//
//  ConfirmationDialogAction.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import Foundation

enum ConfirmationDialogAction: Equatable {
    case display(
        title: String?,
        message: String,
        inputText: String?,
        acceptButtonTitle: String,
        cancelButtonTitle: String
    )
        
    case dismiss(accepted: Bool)
        
    case updateInputText(String)
}
