//
//  ContentView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

struct ContentView: View {
    let store: AppStore
    let environment: AppEnvironment
    
    var body: some View {
        TabView {
            TrackView(
                store: store.trackStore,
                environment: environment.trackEnvironment
            )
            HistoryView()
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
