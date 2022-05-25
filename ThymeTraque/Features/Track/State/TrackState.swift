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
    var activityTimeInterval: TimeInterval
    var activityDescription: String
    
    var activityDescriptionTextFieldFocused: Bool
}

extension TrackState {
    static let live = TrackState(
        trackingStartDate: nil,
        activityTimeIntervalString: "00:00",
        activityTimeInterval: 0.0,
        activityDescription: "",
        activityDescriptionTextFieldFocused: false
    )
    
    static let preview = TrackState(
        trackingStartDate: nil,
        activityTimeIntervalString: "12:34",
        activityTimeInterval: 754.0,
        activityDescription: "",
        activityDescriptionTextFieldFocused: false
    )
}
