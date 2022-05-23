//
//  DateProvider.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation

protocol DateProviderProtocol {
    var date: Date { get }
}

class NowDateProvider: DateProviderProtocol {
    var date: Date { .now }
}

class SetDateProvider: DateProviderProtocol {
    var date: Date
    
    init(date: Date) {
        self.date = date
    }
}
