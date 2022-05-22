//
//  HistoryView.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import SwiftUI

struct HistoryEntry: Equatable, Identifiable {
    let id: UUID = UUID()
    var description: String
    var timeInterval: TimeInterval
}

struct HistoryView: View {
    let entries: Array<HistoryEntry> = [
        .init(description: "My activity 5", timeInterval: 0.33),
        .init(description: "My activity 4", timeInterval: 1.33),
        .init(description: "My activity 3", timeInterval: 2.33),
        .init(description: "My activity 2", timeInterval: 3.33),
        .init(description: "My activity 1", timeInterval: 4.33),
    ]
    
    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.zeroFormattingBehavior = .pad
        return f
    }()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(entries) { entry in
                    HStack {
                        Text(entry.description)
                        Spacer()
                        Text(formatter.string(from: entry.timeInterval) ?? "Unknown")
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
