//
//  ReducerProducer.swift
//  ThymeTraque
//
//  Created by Anton Skripnik on 23.05.2022.
//

import Foundation
import ComposableArchitecture

protocol ReducerProducer {
    associatedtype ReducerState
    associatedtype ReducerAction
    associatedtype ReducerEnvironment
    
    typealias ReducerType = Reducer<ReducerState, ReducerAction, ReducerEnvironment>
    
    func produce() -> ReducerType
}

extension ReducerProducer {
    func eraseToAnyProducer() -> AnyReducerProducer<ReducerState, ReducerAction, ReducerEnvironment> {
        return AnyReducerProducer(self)
    }
}

struct AnyReducerProducer<State, Action, Environment>: ReducerProducer {
    private let produceClosure: (() -> Reducer<State, Action, Environment>)
    
    init<P: ReducerProducer>(_ wrapped: P) where P.ReducerState == State, P.ReducerAction == Action, P.ReducerEnvironment == Environment {
        self.produceClosure = wrapped.produce
    }
    
    func produce() -> Reducer<State, Action, Environment> {
        return produceClosure()
    }
}

protocol CompoundReducerProducer: ReducerProducer {
    var componentProducers: Array<AnyReducerProducer<ReducerState, ReducerAction, ReducerEnvironment>> { get }
}

extension CompoundReducerProducer {
    func produce() -> Reducer<ReducerState, ReducerAction, ReducerEnvironment> {
        .combine(componentProducers.map { $0.produce() })
    }
}
