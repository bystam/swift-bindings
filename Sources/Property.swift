//
//  Copyright © 2018 Frallworks. All rights reserved.
//

import Foundation

/// Represents a value which can be bound to,
/// where changes to it are published to its listeners.
public protocol Property {

    associatedtype Element

    typealias Action = (Element) -> Void

    var value: Element { get }

    /// Create a binding to this value, passing an action to be run on changes.
    ///
    /// The action is called instantly on bind with the current value of this `Property`.
    ///
    /// Note: The binding is alive until the returned `Binding` instance is deallocated.
    func bind(_ action: @escaping Action) -> Binding
}
