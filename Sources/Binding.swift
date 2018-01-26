//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

public final class Binding {

    private var unsubscribe: (() -> Void)?
    private var bindings: [Binding]

    init(bindings: [Binding]) {
        self.bindings = bindings
    }

    init(unsubscribe: @escaping () -> Void) {
        self.unsubscribe = unsubscribe
        self.bindings = []
    }

    deinit {
        unsubscribe?()
    }

    /// Adds this subscription to the given bag.
    func bindLifetime(to bag: BindingBag) {
        bag.bindings.append(self)
    }
}

public final class BindingBag {
    fileprivate var bindings: [Binding] = []
}
