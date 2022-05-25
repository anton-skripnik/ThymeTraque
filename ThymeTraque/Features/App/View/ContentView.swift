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
        .confirmationDialog(
            store: store.confirmationDialogStore,
            environment: environment.confirmationDialogEnvironment
        )
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
