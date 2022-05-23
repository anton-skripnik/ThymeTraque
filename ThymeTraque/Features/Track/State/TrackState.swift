//
//  TrackState.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import SwiftUI

struct TrackState: Equatable {
    var activityTimeInterval: TimeInterval
    var isTracking: Bool
    
    var activityDescription: String
}

extension TrackState {
    static let live = TrackState(
        activityTimeInterval: 754,
        isTracking: false,
        activityDescription: ""
    )
    
    static let preview = TrackState(
        activityTimeInterval: 754,
        isTracking: true,
        activityDescription: ""
    )
}
