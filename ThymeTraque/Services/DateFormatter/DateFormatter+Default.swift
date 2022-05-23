//
//  DateFormatter.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 22.05.2022.
//

import Foundation

extension DateFormatter {
    static let `default`: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
