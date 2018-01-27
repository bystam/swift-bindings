//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

/// A stateless `Bindable` that produces values through a computation
/// based on a set of other `Bindable`s.
public class Computation<T>: Bindable {

    public typealias Element = T

    private let compute: () -> T
    private let binder: (@escaping Action) -> Binding

    private init(compute: @escaping () -> T, binder: @escaping (@escaping Action) -> Binding) {
        self.compute = compute
        self.binder = binder
    }

    public var value: T {
        return compute()
    }

    public func bind(_ action: @escaping Action) -> Binding {
        return binder(action)
    }

    /// Creates a new computation like this, but where value changes
    /// only will be posted if they are not equal according to the given
    /// equality test closure.
    public func distinct(by eq: @escaping (T, T) -> Bool) -> Computation<T> {

        return Computation<T>(
            compute: compute,
            binder: { (action) -> Binding in

                var prev: T?

                let binding = self.bind({ (value) in
                    if prev == nil || !eq(value, prev!) {
                        prev = value
                        action(value)
                    }
                })
                return Binding(bindings: [binding])
        })
    }
}

public extension Computation { // Combinators

    /// Create a `Computation` from a `Bindable`s and a computation closure.
    public static func from<A: Bindable, T>(_ a: A, by transform: @escaping (A.Element) -> T) -> Computation<T> {

        return Computation<T>(

            compute: {
                return transform(a.value)
            },

            binder: { (action) -> Binding in
                let aBinding = a.bind({ (aVal) in
                    action(transform(aVal))
                })
                return Binding(bindings: [aBinding])
        })
    }

    /// Create a `Computation` by combining two `Bindable`s and a computation closure.
    public static func combining<A: Bindable, B: Bindable, T>(_ a: A, _ b: B, by combinator: @escaping (A.Element, B.Element) -> T) -> Computation<T> {

        return Computation<T>(

            compute: {
                return combinator(a.value, b.value)
            },

            binder: { (action) -> Binding in

                var args: (A.Element?, B.Element?) = (nil, nil)
                let propagate: () -> Void = {
                    if let aVal = args.0, let bVal = args.1 {
                        action(combinator(aVal, bVal))
                    }
                }

                let aBinding = a.bind({ (aVal) in
                    args.0 = aVal
                    propagate()
                })
                let bBinding = b.bind({ (bVal) in
                    args.1 = bVal
                    propagate()
                })

                return Binding(bindings: [aBinding, bBinding])
        })
    }

    /// Create a `Computation` by combining three `Bindable`s and a computation closure.
    public static func combining<A: Bindable, B: Bindable, C: Bindable, T>(_ a: A, _ b: B, _ c: C, by combinator: @escaping (A.Element, B.Element, C.Element) -> T) -> Computation<T> {

        return Computation<T>(

            compute: {
                return combinator(a.value, b.value, c.value)
            },

            binder: { (action) -> Binding in

                var args: (A.Element?, B.Element?, C.Element?) = (nil, nil, nil)
                let propagate: () -> Void = {
                    if let aVal = args.0, let bVal = args.1, let cVal = args.2 {
                        action(combinator(aVal, bVal, cVal))
                    }
                }

                let aBinding = a.bind({ (aVal) in
                    args.0 = aVal
                    propagate()
                })
                let bBinding = b.bind({ (bVal) in
                    args.1 = bVal
                    propagate()
                })
                let cBinding = c.bind({ (cVal) in
                    args.2 = cVal
                    propagate()
                })

                return Binding(bindings: [aBinding, bBinding, cBinding])
        })
    }

    /// Create a `Computation` by combining four `Bindable`s and a computation closure.
    public static func combining<A: Bindable, B: Bindable, C: Bindable, D: Bindable, T>(_ a: A, _ b: B, _ c: C, _ d: D, by combinator: @escaping (A.Element, B.Element, C.Element, D.Element) -> T) -> Computation<T> {

        return Computation<T>(

            compute: {
                return combinator(a.value, b.value, c.value, d.value)
            },

            binder: { (action) -> Binding in

                var args: (A.Element?, B.Element?, C.Element?, D.Element?) = (nil, nil, nil, nil)
                let propagate: () -> Void = {
                    if let aVal = args.0, let bVal = args.1, let cVal = args.2, let dVal = args.3 {
                        action(combinator(aVal, bVal, cVal, dVal))
                    }
                }

                let aBinding = a.bind({ (aVal) in
                    args.0 = aVal
                    propagate()
                })
                let bBinding = b.bind({ (bVal) in
                    args.1 = bVal
                    propagate()
                })
                let cBinding = c.bind({ (cVal) in
                    args.2 = cVal
                    propagate()
                })
                let dBinding = d.bind({ (dVal) in
                    args.3 = dVal
                    propagate()
                })

                return Binding(bindings: [aBinding, bBinding, cBinding, dBinding])
        })
    }
}

public extension Computation where T: Equatable {

    /// Same as `distinct(by:)` where standard equality comparison (`==`)  is used.
    public func distinct() -> Computation<T> {
        return distinct(by: ==)
    }
}
