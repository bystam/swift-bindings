//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

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

    func unique(by eq: @escaping (T, T) -> Bool) -> Computation<T> {

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
}

public extension Computation where T: Equatable {

    public func unique() -> Computation<T> {
        return unique(by: ==)
    }
}
