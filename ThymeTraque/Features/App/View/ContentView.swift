//
//  ContentView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TrackView()
            HistoryView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
