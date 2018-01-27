//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

public final class Binding {

    private let unbind: (() -> Void)?
    private let bindings: [Binding]

    init(bindings: [Binding]) {
        self.unbind = nil
        self.bindings = bindings
    }

    init(unbind: @escaping () -> Void) {
        self.unbind = unbind
        self.bindings = []
    }

    deinit {
        unbind?()
    }

    func unbind(with bag: BindingBag) {
        bag.bindings.append(self)
    }
}

public final class BindingBag {
    fileprivate var bindings: [Binding] = []
}
