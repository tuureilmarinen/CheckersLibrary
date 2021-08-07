//
//  CheckersUtilsTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class CheckersUtilsTests: XCTestCase {

    func testMaskIndexes() {
        XCTAssertEqual(CheckersUtils.getSetBitIndexes(UInt64(0b101)), [0, 2])
    }

    static var allTests = [
        ("testMaskIndexes", testMaskIndexes)
    ]
}
