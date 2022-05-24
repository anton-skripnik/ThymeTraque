//
//  TrackAction.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

enum TrackAction: Equatable {
    case toggleTracking
    case trackingTick
    case activityDescriptionChanged(String)
    case persistActivity(description: String, timeInterval: TimeInterval)
    case activityDescriptionTextFieldFocused(Bool)
}
