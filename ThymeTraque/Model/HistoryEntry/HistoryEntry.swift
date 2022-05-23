//
//  HistoryEntry.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

struct HistoryEntry: Identifiable, Equatable {
    var id: Int
    var activityDescription: String
    var timeInterval: TimeInterval
}
