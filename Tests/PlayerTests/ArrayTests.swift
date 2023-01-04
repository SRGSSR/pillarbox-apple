//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class ArrayTests: XCTestCase {
    func testPivotNil() {
        // Given
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["A", "B", "C"]

        // When
        let result = final.elements(of: initial, from: nil)

        // Then
        expect(result).to(equalDiff(["A", "B", "C"]))
    }

    func testPivotNotFoundInOther() {
        // Given
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["A", "B", "C"]

        // When
        let result = final.elements(of: initial, from: "X")

        // Then
        expect(result).to(equalDiff(["A", "B", "C"]))
    }

    func testPivotFound() {
        // Given
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["K", "L", "B", "M", "N"]

        // When
        let result = final.elements(of: initial, from: "B")

        // Then
        expect(result).to(equalDiff(["B", "M", "N"]))
    }

    func testNoCommonItem() {
        // Given
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["X", "Y", "Z"]

        // When
        let result = final.elements(of: initial, from: "B")

        // Then
        expect(result).to(equalDiff(["X", "Y", "Z"]))
    }

    func testCommonItemFoundAfterRemovedPivot_() {
        // Given
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["X", "Y", "Z", "C", "D", "W"]

        // When
        let result = final.elements(of: initial, from: "B")

        // Then
        expect(result).to(equalDiff(["C", "D", "W"]))
    }

    func testCommonItemFoundAfterRemovedPivot() {
        // Given
        let initial = ["A", "B", "C", "D", "E"]
        let final = ["X", "Y", "D", "Z", "C", "W"]

        // When
        let result = final.elements(of: initial, from: "B")

        // Then
        expect(result).to(equalDiff(["C", "W"]))
    }
}
