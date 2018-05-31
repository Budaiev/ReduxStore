//
//  ViewController.swift
//  ReduxSample
//
//  Created by Maxim Kovalko on 5/31/18.
//  Copyright © 2018 Maxim Kovalko. All rights reserved.
//

import UIKit

//State

extension ViewController {
    struct State {
        let counter: Int
    }
}

//Action

extension ViewController {
    enum Action {
        case increase
        case decrease
    }
}

//Reducer

extension ViewController {
    func reducer(_ state: State, _ action: Action) -> State {
        switch action {
        case .increase:
            return State(counter: state.counter + 1)
        case .decrease:
            return State(counter: state.counter - 1)
        }
    }
}

class ViewController: UIViewController {
    lazy var store: Store<State, Action> = Store<State, Action>(
        state: .init(counter: 0),
        reducer: self.reducer
    )
    
    var subscriber: Store<State, Action>.Subscriber!
    
    @IBOutlet var counterLabel: UILabel!

    private func initStore() {
        subscriber = store.subscribe(callback: newState)
    }
    
    func newState(_ newState: State) {
        print(newState)
        counterLabel.text = String(newState.counter)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStore()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(subscriber: subscriber)
    }

    @IBAction func increase(_ sender: UIButton) {
        store.dispatch(.increase)
    }
    
    @IBAction func decrease(_ sender: UIButton) {
        store.dispatch(.decrease)
    }
}
