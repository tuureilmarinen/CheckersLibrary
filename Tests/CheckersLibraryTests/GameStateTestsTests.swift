//
//  GameStateTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class GameStateTestsTests: XCTestCase {

    /// Tests if GameState can validate itself correctly
    func testInternalStateValidator() {
        XCTAssertTrue(
            GameState(
                blackMen: 0b1000,
                blackKings: 0b10,
                whiteMen: 0b1_0000_0000,
                whiteKings: 0b10_0000,
                blackTurn: true
            ).valid)
        XCTAssertFalse(
            GameState(
                blackMen: 0b1000,
                blackKings: 0b11,
                whiteMen: 0b1_0000_0000,
                whiteKings: 0b10_0000,
                blackTurn: false
            ).valid,
            "Black king at nonplayablable square should render state illegal.")
        XCTAssertFalse(
            GameState(
                blackMen: 0b1010,
                blackKings: 0b10,
                whiteMen: 0b1_0000_0000,
                whiteKings: 0b10_0000,
                blackTurn: false
            ).valid,
            "A black man and a black king at the same square should render the state illegal.")
        XCTAssertFalse(
            GameState(
                blackMen: 0b1010,
                blackKings: 0b10,
                whiteMen: 0b1_0000_0010,
                whiteKings: 0b10_0000,
                blackTurn: false
            ).valid,
            "White men should not stay as men at the black end.")
    }

    /// Tests if pieces stay in the squares playable in the english draughts.
    func testPiecesShouldStayInDarkSquares() {
        var state = GameState.defaultStart
        var player = CheckersDeterministicRandomPlayer()
        for _ in 0..<100 {
            let children = state.children
            guard !children.isEmpty else { break }
            state=player.provideMove(state)!
            XCTAssertEqual(state.allPieces & ~GameState.playableSquares, UInt64(0))
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
        var player = CheckersDeterministicRandomPlayer()
        for _ in 0..<100 {
            newState=player.provideMove(state)
            guard newState != nil else { break }
            XCTAssertEqual(
                newState!.whiteMen | newState!.whiteKings | newState!.blackMen | newState!.blackKings,
                newState!.whiteMen ^ newState!.whiteKings ^ newState!.blackMen ^ newState!.blackKings,
                "Pieces should not overlap" +
                    CheckersUtils.encode(dump: state) + " -> " + CheckersUtils.encode(dump: newState!))
            XCTAssertEqual(newState!.allPieces & (~GameState.playableSquares),
                           UInt64(0),
                           "Pieces should stay in playable squares." +
                            CheckersUtils.encode(dump: state) + " -> " + CheckersUtils.encode(dump: newState!))
            XCTAssertLessThanOrEqual(
                newState!.number(of: .BlackMen),
                state.number(of: .BlackMen),
                "Number of black men should not increase.")
            XCTAssertLessThanOrEqual(
                newState!.number(of: .WhiteMen),
                state.number(of: .WhiteMen),
                "Number of white men should not increase. " +
                    CheckersUtils.encode(dump: state) + " -> " + CheckersUtils.encode(dump: newState!))
            XCTAssertEqual(
                state.whiteTurn ? newState!.whitePieces.nonzeroBitCount : newState!.blackPieces.nonzeroBitCount,
                state.whiteTurn ? state.whitePieces.nonzeroBitCount : state.blackPieces.nonzeroBitCount,
                "Player should not lose any pieces during his own turn." +
                    CheckersUtils.encode(dump: state) + " -> " + CheckersUtils.encode(dump: newState!))
            XCTAssertLessThanOrEqual(
                state.blackTurn ? newState!.number(of: .WhiteKings) : newState!.number(of: .BlackKings),
                state.blackTurn ? state.number(of: .WhiteKings) : state.number(of: .BlackKings),
                "Pieces should not turn into kings when player does not play.")
            state=newState!
        }
    }
    
    func testNumberOf() {
        let state=GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1010_1010,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0010_1000_0101_0100_0000_0000,
            whiteMen: 0b0001_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0100_0000_0000_1010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: true
        )
        XCTAssertEqual(state.number(of: .Black), 10)
        XCTAssertEqual(state.number(of: .BlackMen), 4)
        XCTAssertEqual(state.number(of: .BlackKings), 6)
        XCTAssertEqual(state.number(of: .White), 5)
        XCTAssertEqual(state.number(of: .WhiteMen), 2)
        XCTAssertEqual(state.number(of: .WhiteKings), 3)
        XCTAssertEqual(state.number(of: .All), 15)
        XCTAssertEqual(state.number(of: .Empty), 17)
    }

    /// Tests that men turn into kings when and only when they reach the opposite end of the board.
    func testMenTurnIntoKings() {
        var state=CheckersUtils.decode(dump: "0000000000400040000000000000000000000002001000000000000000000000W")
        for child in state!.children {
            XCTAssertEqual(child.number(of: .WhiteMen), 1)
            XCTAssertEqual(child.number(of: .WhiteKings), 1)
            XCTAssertEqual(child.number(of: .BlackMen), 1)
            XCTAssertEqual(child.number(of: .BlackKings), 1)
        }
        state=PortableDraughtsNotation.decode("W:W5,10:B6,8")
        state=CheckersUtils.decode(dump: "0000000040100010000400000000000000000000000000000000000000000000W")!
        for child in state!.children {
            XCTAssertEqual(
                CheckersUtils.decode(dump: "0800000040000010000000000000000000000000000000000000000000000000B"),
                child)
        }
        state=PortableDraughtsNotation.decode("B:W25,29:B21,K22")
        state=CheckersUtils.decode(dump: "0000000000000000000000000000000000000000102000000400000040000000B")
        for child in state!.children {
            XCTAssertEqual(child,
                           CheckersUtils.decode(
                            dump: "0000000000000000000000000000000000000000002000000000000040200000W"
                           )
            )
        }
    }

    static var allTests = [
        ("testPiecesShouldStayInDarkSquares", testPiecesShouldStayInDarkSquares),
        ("testPieceCount", testPieceCount)
    ]
}
