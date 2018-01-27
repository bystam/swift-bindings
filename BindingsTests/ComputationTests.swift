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

    func testComputationInitialValue_Deep() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp1 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let sumComp2 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let deepComp = Computation<Int>.combining(sumComp1, sumComp2, by: { $0 + $1 })

        // Act
        // Assert
        XCTAssertEqual(deepComp.value, 2 * (3 + 5))
    }

    func testComputationValueChange_Deep() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp1 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let sumComp2 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let deepComp = Computation<Int>.combining(sumComp1, sumComp2, by: { $0 + $1 })

        // Act
        aInt.set(10)

        // Assert
        XCTAssertEqual(deepComp.value, 2 * (10 + 5))
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

    func testComputation_Unique_Inherent() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>
            .combining(aInt, bInt, by: { $0 + $1 })
            .distinct()

        let exp = expectation(description: "notify1")
        exp.expectedFulfillmentCount = 3

        sumComp.bind { (_) in
            exp.fulfill()
        }.unbind(with: bag)

        // Act
        aInt.set(10)
        aInt.set(10)
        aInt.set(10)
        aInt.set(11)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
        }
    }

    func testComputation_Unique_Custom() {

        struct S {
            let id: Int
        }

        // Arrange
        let aStruct = Variable<S>(S(id: 1))
        let bStruct = Variable<S>(S(id: 2))
        let sumComp = Computation<S>
            .combining(aStruct, bStruct, by: { $0.id > $1.id ? $0 : $1 })
            .distinct(by: { $0.id == $1.id })

        let exp = expectation(description: "notify1")
        exp.expectedFulfillmentCount = 3

        sumComp.bind { (_) in
            exp.fulfill()
        }.unbind(with: bag)

        // Act
        aStruct.set(S(id: 3))
        aStruct.set(S(id: 3))
        aStruct.set(S(id: 3))
        bStruct.set(S(id: 4))

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(sumComp.value.id, 4)
        }
    }

    func testComputation_Unique_PropagatesToAllBinders() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>
            .combining(aInt, bInt, by: { $0 + $1 })
            .distinct()

        let exp1 = expectation(description: "notify1")
        exp1.expectedFulfillmentCount = 2
        let exp2 = expectation(description: "notify2")
        exp2.expectedFulfillmentCount = 2

        sumComp.bind { (_) in
            exp1.fulfill()
        }.unbind(with: bag)
        sumComp.bind { (_) in
            exp2.fulfill()
        }.unbind(with: bag)

        // Act
        aInt.set(10)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
        }
    }

    func testComputation_Combined3() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let cInt = Variable<Int>(7)
        let maxComp = Computation<Int>
            .combining(aInt, bInt, cInt, by: { max($0, $1, $2) })

        let exp = expectation(description: "notify1")
        exp.expectedFulfillmentCount = 3

        // Act
        var values: [Int] = []
        binding = maxComp.bind { (max) in
            values.append(max)
            exp.fulfill()
        }

        aInt.set(10)
        cInt.set(12)

        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
            XCTAssertEqual(maxComp.value, 12)
            XCTAssertEqual(values, [7, 10, 12])
        }
    }


    // MARK: - Binding tests

    func testComputation_BindingCount_Depth1() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })

        // Act
        binding = sumComp.bind { _ in }

        // Assert
        XCTAssertEqual(aInt.numberOfBindings, 1)
        XCTAssertEqual(bInt.numberOfBindings, 1)
    }

    func testComputation_BindingCount_Depth2() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp1 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let sumComp2 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let deepComp = Computation<Int>.combining(sumComp1, sumComp2, by: { $0 + $1 })

        // Act
        deepComp.bind { _ in }.unbind(with: bag)

        // Assert
        XCTAssertEqual(aInt.numberOfBindings, 2)
        XCTAssertEqual(bInt.numberOfBindings, 2)
    }

    func testComputation_UnbindingCount_Depth1() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })

        // Act
        // Assert
        autoreleasepool {
            binding = sumComp.bind { _ in }
            XCTAssertEqual(aInt.numberOfBindings, 1)
            XCTAssertEqual(bInt.numberOfBindings, 1)
            binding = nil
        }

        XCTAssertEqual(aInt.numberOfBindings, 0)
        XCTAssertEqual(bInt.numberOfBindings, 0)
    }

    func testComputation_UnbindingCount_Depth2() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp1 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let sumComp2 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let deepComp = Computation<Int>.combining(sumComp1, sumComp2, by: { $0 + $1 })

        // Act
        // Assert
        autoreleasepool {
            binding = deepComp.bind { _ in }
            XCTAssertEqual(aInt.numberOfBindings, 2)
            XCTAssertEqual(bInt.numberOfBindings, 2)
            binding = nil
        }

        XCTAssertEqual(aInt.numberOfBindings, 0)
        XCTAssertEqual(bInt.numberOfBindings, 0)
    }

    func testComputation_Undbind_StopsNotify() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let exp = expectation(description: "notify")
        exp.expectedFulfillmentCount = 1

        // Act
        autoreleasepool {
            binding = sumComp.bind { (val) in
                exp.fulfill()
            }
            binding = nil
        }

        aInt.set(10)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
        }
    }

    func testComputation_Undbind_StopsNotify_Deep() {
        // Arrange
        let aInt = Variable<Int>(3)
        let bInt = Variable<Int>(5)
        let sumComp1 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let sumComp2 = Computation<Int>.combining(aInt, bInt, by: { $0 + $1 })
        let deepComp = Computation<Int>.combining(sumComp1, sumComp2, by: { $0 + $1 })
        let exp = expectation(description: "notify")
        exp.expectedFulfillmentCount = 1

        // Act
        autoreleasepool {
            binding = deepComp.bind { (val) in
                exp.fulfill()
            }
            binding = nil
        }

        aInt.set(10)

        // Assert
        waitForExpectations(timeout: 0.1) { (error) in
            XCTAssertNil(error)
        }
    }
}
