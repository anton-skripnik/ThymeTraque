//
//  TrackState.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import SwiftUI

struct TrackState: Equatable {
    var trackingStartDate: Date?
    var isTracking: Bool {
        trackingStartDate != nil
    }
    
    var activityTimeIntervalString: String
    var activityDescription: String
}

extension TrackState {
    static let live = TrackState(
        trackingStartDate: nil,
        activityTimeIntervalString: "12:34",
        activityDescription: ""
    )
    
    static let preview = TrackState(
        trackingStartDate: nil,
        activityTimeIntervalString: "12:34",
        activityDescription: ""
    )
}
