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

    func testGetMove() {
        let from = GameState(blackMen: 36680807752008714, blackKings: 0, whiteMen: 4971974169005670400, whiteKings: 549773115680, blackTurn: true)
        let to = GameState(blackMen: 36685205530084362, blackKings: 0, whiteMen: 4971974134645932032, whiteKings: 549773115680, blackTurn: false)
        let move=CheckersUtils.getMove(from, to)
        XCTAssertEqual(move.from, 28)
        XCTAssertEqual(move.to, 42)
        XCTAssertEqual(move.captured, [35])
        XCTAssertEqual(move.next, to)
        XCTAssertEqual(move.previous, from)
    }

    static var allTests = [
        ("testMaskIndexes", testMaskIndexes)
    ]
}
