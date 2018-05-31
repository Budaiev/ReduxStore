# ReduxStore
Redux Store implementation for Swift

# Getting Started

## Reducer
```swift
typealias Reducer<StateType, ActionType> = (_ state: StateType, _ action: ActionType) -> StateType
```

## Store
```swift
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
```

# Example
```swift
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
```

### State

```swift
extension ViewController {
    struct State {
        let counter: Int
    }
}
```

### Action
```swift
extension ViewController {
    enum Action {
        case increase
        case decrease
    }
}
```

### Reducer
```swift
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
```
