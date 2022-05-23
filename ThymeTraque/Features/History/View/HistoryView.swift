//
//  HistoryView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct HistoryView: View {
    let store: HistoryStore
    let environment: HistoryEnvironment
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Group {
                    if viewStore.entries.isEmpty {
                        Text("No entries yet. Start by tapping the big button on the Track screen.")
                            .padding()
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(viewStore.entries) { entry in
                                HStack {
                                    Text(entry.activityDescription)
                                    Spacer()
                                    Text(environment.timeIntervalFormatter.string(from: entry.timeInterval))
                                        .foregroundColor(.gray)
                                }
                            }
                            .onDelete { indexes in
                                for idx in indexes {
                                    let id = viewStore.entries[idx].id
                                    viewStore.send(.removeEntry(id: id))
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("My activities")
            }
            // https://stackoverflow.com/questions/65316497/swiftui-navigationview-navigationbartitle-layoutconstraints-issue
            .navigationViewStyle(.stack)
            .onAppear {
                viewStore.send(.refresh)
            }
        }
        .tabItem(constructTabItemLabel)
    }
    
    func constructTabItemLabel() -> some View {
        VStack {
            Image(systemName: "list.bullet")
            Text("History")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(
            store: .preview,
            environment: .preview
        )
    }
}
