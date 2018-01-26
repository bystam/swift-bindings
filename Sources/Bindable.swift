//
//  Copyright © 2018 Frallan. All rights reserved.
//

import Foundation

public protocol Bindable {

    associatedtype Element

    typealias Action = (Element) -> Void

    var value: Element { get }

    func bind(_ action: @escaping Action) -> Binding
}
