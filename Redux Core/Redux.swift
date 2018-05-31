//
//  Redux.swift
//  ReduxSample
//
//  Created by Maxim Kovalko on 5/31/18.
//  Copyright © 2018 Maxim Kovalko. All rights reserved.
//

import Foundation

typealias Reducer<StateType, ActionType> = (_ state: StateType, _ action: ActionType) -> StateType

final class Store<StateType, ActionType> {
    var state: StateType
    let reducer: Reducer<StateType, ActionType>
    var subscribers: [Subscriber] = []
    
    let queue = OperationQueue.main
    
    final class Subscriber: Hashable {
        let callback: (StateType) -> Void
        init(callback: @escaping (StateType) -> Void) {
            self.callback = callback
        }
        static func == (left: Subscriber, right: Subscriber) -> Bool { return left == right }
        var hashValue: Int { return ObjectIdentifier(self).hashValue }
    }
    
    init(state: StateType, reducer: @escaping Reducer<StateType, ActionType>) {
        self.state = state
        self.reducer = reducer
    }
    
    func dispatch(_ action: ActionType) {
        queue.addOperation {
            self.state = self.reducer(self.state, action)
            self.subscribers.forEach { $0.callback(self.state) }
        }
    }
    
    func subscribe(callback: @escaping (StateType) -> Void) -> Subscriber {
        let subscriber = Subscriber(callback: callback)
        
        queue.addOperation {
            self.subscribers.append(subscriber)
            subscriber.callback(self.state)
        }
        
        return subscriber
    }
    
    func unsubscribe(subscriber: Subscriber) {
        queue.addOperation {
            guard let index = self.subscribers.index(where: { $0 == subscriber }) else { return }
            self.subscribers.remove(at: index)
        }
    }
}
