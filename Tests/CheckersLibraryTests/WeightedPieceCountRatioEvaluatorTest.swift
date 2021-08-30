//
//  WeightedPieceCountRatioEvaluator.swift
//  CheckersLibraryTests
//
//  Created by Tuure Ilmarinen on 25.8.2021.
//

import XCTest
@testable import CheckersLibrary

class WeightedPieceCountRatioEvaluatorTest: XCTestCase {

    func testEvaluateWeights() throws {
        let evaluator = WeightedPieceCountRatioEvaluator(
            piece: 10,
            king: 100,
            turn: 20,
            remainingMen: 1000,
            remainingKings: 2000
        )
        // 2bm 3bk 4wm 6wk WT
        let state2bm3mk4wm6wkWT = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1010,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_1000_0000_0100_0000_0000,
            whiteMen: 0b0101_0101_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_1000_1010_0000_0101_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000,
            blackTurn: false
        )
        let excepted2bm3mk4wm6wkWT = ((4.0+6.0)/(2.0+3.0))*10.0 + Double((6.0/4.0)*100.0) + 20.0*1.0 - 1
        XCTAssertEqual(excepted2bm3mk4wm6wkWT, evaluator.evaluate(state2bm3mk4wm6wkWT))
        let state4bm6bk2wm3wkWT = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1010_1010,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0010_1000_0101_0100_0000_0000,
            whiteMen: 0b0001_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0100_0000_0000_1010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: false
        )
        let excepted4bm6bk2wm3wkWT = (((4.0+6.0)/(2.0+3.0))*10.0 + Double((6.0/4.0)*100.0) - 1) * -1
        XCTAssertEqual(excepted4bm6bk2wm3wkWT, evaluator.evaluate(state4bm6bk2wm3wkWT))
        let state2bm3bkBT = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0010_0000_0100_0000_0000_0000_0000_0000_0000,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_1000_0001_0000_0010_0000_0000_0000_0000_0000,
            whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: true)
        let excepted2bm3bkBT: Double = (1000.0*2.0 + 2000.0*3.0) * -1.0
        XCTAssertEqual(excepted2bm3bkBT, evaluator.evaluate(state2bm3bkBT))
        let state2wm3wkWT = GameState(
            blackMen: 0,
            blackKings: 0,
            whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0010_0000_0100_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_1000_0001_0000_0010_0000_0000_0000_0000_0000,
            blackTurn: true)
        let excepted2wm3wkBT: Double = 1000.0*2.0 + 2000.0*3.0
        XCTAssertEqual(excepted2wm3wkBT, evaluator.evaluate(state2wm3wkWT))
    }
}
