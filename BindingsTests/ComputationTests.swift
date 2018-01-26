//
//  Copyright © 2018 Frallan. All rights reserved.
//

import XCTest
@testable import Bindings

class ComputationTests: XCTestCase {

    var binding: Binding?
    var bag = BindingBag()

    override func setUp() {
        binding = nil
        bag = BindingBag()
    }

    func testComputationInitialValue() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })

        // Act
        // Assert
        XCTAssertEqual(sumComp.value, 3 + 5)
    }

    func testComputationValueChange() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })

        // Act
        aInt.set(10)

        // Assert
        XCTAssertEqual(sumComp.value, 10 + 5)
    }

    func testComputationChangeNotify_OnBind() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let exp = expectation(description: "notify")

        // Act
        binding = sumComp.bind { (val) in
            exp.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(sumComp.value, 3 + 5)
        }
    }

    func testComputationChangeNotify_OnSourceChange() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let exp = expectation(description: "notify")
        exp.expectedFulfillmentCount = 3
        binding = sumComp.bind { (val) in
            exp.fulfill()
        }

        aInt.set(10)
        bInt.set(4)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(sumComp.value, 10 + 4)
        }
    }

    func testComputation_Unique_PropagatesToAllBinders() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>
            .combining(aInt, bInt, by: { $0 + $1 })
            .unique()

        let exp1 = expectation(description: "notify1")
        exp1.expectedFulfillmentCount = 2
        let exp2 = expectation(description: "notify2")
        exp2.expectedFulfillmentCount = 2

        sumComp.bind { (_) in
            exp1.fulfill()
        }.bindLifetime(to: bag)
        sumComp.bind { (_) in
            exp2.fulfill()
        }.bindLifetime(to: bag)

        // Act
        aInt.set(10)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
        }
    }
}
