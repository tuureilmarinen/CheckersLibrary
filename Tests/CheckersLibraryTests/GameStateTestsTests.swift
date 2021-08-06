//
//  GameStateTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class GameStateTestsTests: XCTestCase {

    func testPiecesShouldStayInDarkSquares() {
        var state = GameState.defaultStart
        for _ in 0..<100 {
            let children = state.children
            guard !children.isEmpty else { break }
            state=children.randomElement()!
            XCTAssertEqual(state.allPieces & ~GameState.darkSquares, UInt64(0))
        }
        XCTAssertEqual(CheckersUtils.getMaskIndexes(UInt64(0b101)), [0, 2])
    }
    func testPieceCount() {
        var state = GameState.defaultStart
        var newState: GameState?
        for _ in 0..<100 {
            newState=state.children.randomElement()
            guard newState != nil else { break }
            XCTAssertLessThanOrEqual(
                newState!.blackMen.nonzeroBitCount,
                state.blackMen.nonzeroBitCount,
                "Number of black men should not increase.")
            XCTAssertLessThanOrEqual(
                newState!.whiteMen.nonzeroBitCount,
                state.whiteMen.nonzeroBitCount,
                "Number of white men should not increase.")
            XCTAssertEqual(
                state.whiteTurn ? newState!.whitePieces.nonzeroBitCount : newState!.blackPieces.nonzeroBitCount,
                state.whiteTurn ? state.whitePieces.nonzeroBitCount : state.blackPieces.nonzeroBitCount,
                "Player should not lose any pieces during his own turn.")
            XCTAssertLessThanOrEqual(
                state.blackTurn ? newState!.whiteKings.nonzeroBitCount : newState!.blackKings.nonzeroBitCount,
                state.blackTurn ? state.whiteKings.nonzeroBitCount : state.blackKings.nonzeroBitCount,
                "Pieces should not turn into kings when player does not play.")
            state=newState!
        }
    }

    static var allTests = [
        ("testPiecesShouldStayInDarkSquares", testPiecesShouldStayInDarkSquares),
        ("testPieceCount", testPieceCount)
    ]
}
