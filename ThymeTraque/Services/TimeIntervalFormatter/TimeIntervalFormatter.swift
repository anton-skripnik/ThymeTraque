//
//  TimeIntervalFormatter.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

protocol TimeIntervalFormatterProtocol {
    func string(from timeInterval: TimeInterval) -> String
}

class TimeIntervalFormatter: TimeIntervalFormatterProtocol {
    private let dateComponentFormatter: DateComponentsFormatter = {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [ .minute, .second ]
        dcf.zeroFormattingBehavior = .pad
        
        return dcf
    }()
    
    func string(from timeInterval: TimeInterval) -> String {
        return dateComponentFormatter.string(from: timeInterval) ?? "Unknown"
    }
}
