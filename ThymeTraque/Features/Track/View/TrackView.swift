//
//  TrackView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

struct TrackView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .tabItem(constructTabItemLabel)
    }
    
    func constructTabItemLabel() -> some View {
        VStack {
            Image(systemName: "timer")
            Text("Track")
        }
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView()
    }
}
