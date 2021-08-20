//
//  GameStateTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class GameStateTestsTests: XCTestCase {

    /// Tests if pieces stay in the squares playable in the english draughts.
    func testPiecesShouldStayInDarkSquares() {
        var state = GameState.defaultStart
        for _ in 0..<100 {
            let children = state.children
            guard !children.isEmpty else { break }
            state=children.randomElement()!
            XCTAssertEqual(state.allPieces & ~GameState.darkSquares, UInt64(0))
        }
        XCTAssertEqual(CheckersUtils.getSetBitIndexes(UInt64(0b101)), [0, 2])
    }

    /// Preforms simple tests with the piececounts.
    /// - Tests that the total number of pieces does not increase.
    /// - The player in turn does not lose pieces during his own turn.
    /// - Men can turn into kings only during players own turn.
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

    /// Tests that men turn into kings when and only when they reach the opposite end of the board.
    func testMenTurnIntoKings() {
        var state=PortableDraughtsNotation.PDNfenToGameState("W:W6,8:BK20,22")
        for child in state!.children {
            XCTAssertEqual(child.whiteMen.nonzeroBitCount, 1)
            XCTAssertEqual(child.whiteKings.nonzeroBitCount, 1)
            XCTAssertEqual(child.blackMen.nonzeroBitCount, 1)
            XCTAssertEqual(child.blackKings.nonzeroBitCount, 1)
        }
        state=PortableDraughtsNotation.PDNfenToGameState("W:W5,10:B6,8")
        for child in state!.children {
            XCTAssertEqual(child.whiteMen, UInt64(0b1_0000_0000))
            XCTAssertEqual(child.whiteKings, UInt64(0b10))
            XCTAssertEqual(child.blackMen, UInt64(0b1000_0000_0000_0000))
            XCTAssertEqual(child.blackKings, 0)
        }
        state=PortableDraughtsNotation.PDNfenToGameState("B:W25,29:B21,K22")
        for child in state!.children {
            XCTAssertEqual(child, PortableDraughtsNotation.PDNfenToGameState("W:W29:BK30,K22"))
        }
    }

    static var allTests = [
        ("testPiecesShouldStayInDarkSquares", testPiecesShouldStayInDarkSquares),
        ("testPieceCount", testPieceCount)
    ]
}
