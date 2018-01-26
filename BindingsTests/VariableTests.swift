//
//  Copyright © 2018 Frallan. All rights reserved.
//

import XCTest
@testable import Bindings

class BindingsTests: XCTestCase {

    var binding: Binding?

    override func setUp() {
        binding = nil
    }
    
    func testVariableInitialValue() {
        // Arrange
        let int = Variable<Int>(5)

        // Act
        // Assert
        XCTAssertEqual(int.value, 5)
    }

    func testVariableValueChange() {
        // Arrange
        let int = Variable<Int>(5)

        // Act
        int.set(7)

        // Assert
        XCTAssertEqual(int.value, 7)
    }

    func testVariableChangeNotify_OnBind() {
        // Arrange
        let int = Variable<Int>(5)
        let exp = expectation(description: "notify")

        // Act
        binding = int.bind { (val) in
            XCTAssertEqual(val, 5)
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(int.value, 5)
        }
    }

    func testVariableChangeNotify_OnSet() {
        // Arrange
        let int = Variable<Int>(5)
        let exp = expectation(description: "notify")
        exp.expectedFulfillmentCount = 2
        binding = int.bind { (val) in
            exp.fulfill()
        }

        // Act
        int.set(7)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(int.value, 7)
        }
    }

    func testDeallocBindingDoesNotNotify() {
        // Arrange
        let exp = expectation(description: "notify")
        exp.expectedFulfillmentCount = 1
        let int = Variable<Int>(5)

        autoreleasepool {
            binding = int.bind { (val) in
                exp.fulfill()
            }
            binding = nil
        }

        // Act
        int.set(7)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(int.value, 7)
        }
    }
}
