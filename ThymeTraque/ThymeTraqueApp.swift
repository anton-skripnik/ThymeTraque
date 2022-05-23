//
//  ThymeTraqueApp.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

@main
struct ThymeTraqueApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: AppStoreProducer.live.produce(),
                environment: .live
            )
        }
    }
}
