//
//  TrackView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct TrackView: View {
    let store: TrackStore
    let environment: TrackEnvironment
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @FocusState private var textFieldFocused: Bool
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if verticalSizeClass == .regular {
                    RegularVerticalTrackViewLayout(
                        store: store,
                        environment: environment,
                        textFieldFocused: $textFieldFocused
                    )
                } else {
                    CompactVerticalTrackViewLayout(
                        store: store,
                        environment: environment,
                        textFieldFocused: $textFieldFocused
                    )
                }
            }
            .synchronize(
                $textFieldFocused,
                viewStore.binding(get: \.activityDescriptionTextFieldFocused,
                                  send: { TrackAction.activityDescriptionTextFieldFocused($0) })
            )
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

struct RegularVerticalTrackViewLayout: View {
    let store: TrackStore
    let environment: TrackEnvironment
    
    var textFieldFocused: FocusState<Bool>.Binding
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                
                VStack {
                    Text(viewStore.activityTimeIntervalString)
                        .font(.system(size: 70.0, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white)
                        .colorMultiply(viewStore.isTracking ? .primary : .secondary)
                        .animation(.easeInOut, value: viewStore.isTracking)
                    
                    Button {
                        viewStore.send(.toggleTracking)
                    } label: {
                        Image(systemName: viewStore.isTracking ? "stop.circle" : "play.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 240.0)
                
                Spacer()
                
                TextField(
                    "Tap here to add description",
                    text: viewStore.binding(
                        get: \.activityDescription,
                        send: { .activityDescriptionChanged($0) }
                    )
                )
                .focused(textFieldFocused)
                .multilineTextAlignment(.center)
                .font(.body)
                .padding()
                
                Spacer()
            }
        }
    }
}


struct CompactVerticalTrackViewLayout: View {
    let store: TrackStore
    let environment: TrackEnvironment
    
    var textFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                
                HStack {
                    Text(viewStore.activityTimeIntervalString)
                        .font(.system(size: 50.0, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white)
                        .colorMultiply(viewStore.isTracking ? .primary : .secondary)
                        .animation(.easeInOut, value: viewStore.isTracking)
                    
                    Button {
                        viewStore.send(.toggleTracking)
                    } label: {
                        Image(systemName: viewStore.isTracking ? "stop.circle" : "play.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(height: 50.0)
                }
                
                TextField(
                    "Tap here to add description",
                    text: viewStore.binding(
                        get: \.activityDescription,
                        send: { .activityDescriptionChanged($0) }
                    )
                )
                .focused(textFieldFocused)
                .multilineTextAlignment(.center)
                .font(.body)
                .padding()
                
                Spacer()
            }
        }
    }
    
}

extension View {
    func synchronize<Value: Equatable>(
        _ first: FocusState<Value>.Binding,
        _ second: Binding<Value>
    ) -> some View {
        self
            .onChange(of: first.wrappedValue, perform: { second.wrappedValue = $0 })
            .onChange(of: second.wrappedValue, perform: { first.wrappedValue = $0 })
        
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TrackView(
                store: .preview,
                environment: .preview
            )
            .previewInterfaceOrientation(.landscapeRight)

            TrackView(
                store: .preview,
                environment: .preview
            )
            .preferredColorScheme(.light)

            TrackView(
                store: .preview,
                environment: .preview
            )
            .preferredColorScheme(.dark)
        }
    }
}
