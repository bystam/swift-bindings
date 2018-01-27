//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

/// A stateful `Bindable` that wraps a single value.
public class Variable<T>: Bindable {

    public typealias Element = T

    public private(set) var value: T

    private var nextBindingId = 0
    private var actions: [Int : Action] = [:]

    public init(_ value: T) {
        self.value = value
    }

    public func bind(_ action: @escaping Action) -> Binding {
        action(value)

        let id = nextBindingId
        nextBindingId += 1

        actions[id] = action

        return Binding(unbind: { [weak self] in
            self?.actions[id] = nil
        })
    }

    /// Set the value of this `Variable`, propagating the change to any bindings.
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
