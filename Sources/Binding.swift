//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

public final class Binding {

    private var unbind: (() -> Void)?
    private var bindings: [Binding]

    init(bindings: [Binding]) {
        self.bindings = bindings
    }

    init(unbind: @escaping () -> Void) {
        self.unbind = unbind
        self.bindings = []
    }

    deinit {
        unbind?()
    }

    /// Adds this subscription to the given bag.
    func bindLifetime(to bag: BindingBag) {
        bag.bindings.append(self)
    }
}

public final class BindingBag {
    fileprivate var bindings: [Binding] = []
}
