//
//  HistoryView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

struct HistoryView: View {
    let entries: Array<HistoryEntry> = [
        .init(id: 1, activityDescription: "My activity 5", timeInterval: 0.33),
        .init(id: 2, activityDescription: "My activity 4", timeInterval: 1.33),
        .init(id: 3, activityDescription: "My activity 3", timeInterval: 2.33),
        .init(id: 4, activityDescription: "My activity 2", timeInterval: 3.33),
        .init(id: 5, activityDescription: "My activity 1", timeInterval: 4.33),
    ]
    
    let formatter: TimeIntervalFormatterProtocol = TimeIntervalFormatter()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(entries) { entry in
                    HStack {
                        Text(entry.activityDescription)
                        Spacer()
                        Text(formatter.string(from: entry.timeInterval))
                            .foregroundColor(.gray)
                    }
                }
                .onDelete { indexes in
                    print("Delete")
                }
            }
            .navigationTitle("My activities")
            .listStyle(.plain)
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
        HistoryView()
    }
}
