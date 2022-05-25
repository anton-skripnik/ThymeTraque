//
//  ConfirmationDialogState.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 25.05.2022.
//

import Foundation

struct ConfirmationDialogState: Equatable {
    var isPresented: Bool = false
    var title: String?
    var message: String = ""
    var inputText: String?
    
    var acceptButtonTitle: String = "OK"
    var cancelButtonTitle: String = "Cancel"
}


extension ConfirmationDialogState {
    static let live = ConfirmationDialogState(
        isPresented: false,
        title: nil,
        message: "Some message",
        inputText: nil,
        acceptButtonTitle: "OK",
        cancelButtonTitle: "Cancel"
    )
    
    static let preview = ConfirmationDialogState(
        isPresented: false,
        title: nil,
        message: "Some message",
        inputText: nil,
        acceptButtonTitle: "OK",
        cancelButtonTitle: "Cancel"
    )
}
