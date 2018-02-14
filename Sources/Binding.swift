//
//  Copyright © 2018 Frallworks. All rights reserved.
//

import Foundation

/// Represents a binding to a `Property` value. Deallocate to stop.
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

    /// Add this to a group of bindings.
    public func unbind(with group: BindingGroup) {
        group.bindings.append(self)
    }
}

public final class BindingGroup {
    fileprivate var bindings: [Binding] = []

    public init() {}
}
