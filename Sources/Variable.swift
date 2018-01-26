//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

public class Variable<T>: Bindable {

    public typealias Element = T

    public private(set) var value: T

    private var nextSubscriptionId = 0
    private var actions: [Int : Action] = [:]

    public init(_ value: T) {
        self.value = value
    }

    public func bind(_ action: @escaping Action) -> Binding {
        action(value)

        let id = nextSubscriptionId
        nextSubscriptionId += 1

        actions[id] = action

        return Binding(unsubscribe: { [weak self] in
            self?.actions[id] = nil
        })
    }

    public func set(_ value: T) {
        self.value = value
        actions.values.forEach { $0(value) }
    }
}

// for testing
internal extension Variable {

    var numberOfBindings: Int {
        return actions.count
    }
}
