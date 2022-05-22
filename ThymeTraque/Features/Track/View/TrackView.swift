//
//  TrackView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

struct TrackView: View {
    @State private var editingText: Bool = false
    @FocusState private var textFieldFocused: Bool
    @State private var textFieldText: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Text("00:00")
                    .font(.system(size: 70.0, weight: .ultraLight, design: .rounded))
                
                Button {
                    print("Button tapped")
                } label: {
                    Image(systemName: "stop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 240.0)
            
            Spacer()
            
            TextField("Tap here to edit your activity description", text: $textFieldText)
                .multilineTextAlignment(.center)
                .font(.body)
                .padding()
            
            Spacer()
        }
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
        Group {
            TrackView()
                .preferredColorScheme(.light)
            TrackView()
                .preferredColorScheme(.dark)
        }
    }
}
