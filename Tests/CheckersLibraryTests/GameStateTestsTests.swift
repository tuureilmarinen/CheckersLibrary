//
//  GameStateTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class GameStateTestsTests: XCTestCase {

    func testCorrectAmountOfChildren() {
        let children = GameState.defaultStart.children
        XCTAssertEqual(children.count, 7)
        let legalMovesFromStart = [
            "0101010110101010000101011000000000000000404040400404040440404040W",
            "0101010110101010000101010010000000000000404040400404040440404040W",
            "0101010110101010010001010010000000000000404040400404040440404040W",
            "0101010110101010010001010000100000000000404040400404040440404040W",
            "0101010110101010010100010000100000000000404040400404040440404040W",
            "0101010110101010010100010000001000000000404040400404040440404040W",
            "0101010110101010010101000000001000000000404040400404040440404040W"].map { try! GameState(dump: $0)}
        // swiftlint:disable:previous force_try
        for legalChild in legalMovesFromStart {
            XCTAssert(children.contains(legalChild), "default start has no child \(legalChild)")
        }
    }

    func testPiecesShouldNotOverlap() {

    }

    func testShouldMoveOnlyOnePiece() {
        // 0100010800101000040002041000404008000402102080400004000140400000W
        // W:WK4,9,12,15,16,K17,19,K23,24,26,29,30:B1,3,6,7,K11,13,K20,21,K22,28
        let stateA = GameState(
            blackMen: 0b0000_0000_1000_0000_0000_0001_0000_0000_0000_0001_0000_0000_0001_0100_0010_0010,
            blackKings: 0b0000_0000_0000_0000_0000_0100_1000_0000_0000_0000_0010_0000_0000_0000_0000_0000,
            whiteMen: 0b0000_0101_0000_1000_0100_0000_0010_0000_0101_0000_1000_0010_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0001_0000_0000_0010_0000_0000_0000_0000_0000_0000_1000_0000,
            blackTurn: false)
        let whiteMen = stateA.pieces(.WhiteMen).pieces
        let whiteKings = stateA.pieces(.WhiteKings).pieces
        let white = stateA.pieces(.White).pieces
        for child in stateA.children {
            XCTAssertLessThanOrEqual(
                (child.pieces(.WhiteMen).pieces^whiteMen).nonzeroBitCount,
                2,
                "Difference in own pieces should be less or equal 2")
            XCTAssertLessThanOrEqual(
                (child.pieces(.WhiteKings).pieces^whiteKings).nonzeroBitCount,
                2,
                "Difference in own pieces should be less or equal 2")
            XCTAssertEqual(
                (child.pieces(.White).pieces^white).nonzeroBitCount,
                2,
                "Difference in own pieces should be equal 2")
        }
    }

    func testEncode() {
        let stateA = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1010_1010_0101_0101_1010_1010,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0101_0101_1010_1010_0101_0101_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: true
        )
        let stateB = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0010_0010_0000_0000_0000_0000_0000_0000_0010_1000,
            blackKings: 0b0000_0000_0000_0000_0100_0100_0000_0000_0000_0000_0000_0010_0000_0000_0000_0010,
            whiteMen: 0b0000_0000_1000_0000_0001_0001_1000_1000_0001_0101_1000_0000_0000_0001_0000_0000,
            whiteKings: 0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000,
            blackTurn: false
        )
        XCTAssertEqual(stateA.encode(to: String.self), "0101010110101010010101010000000000000000404040400404040440404040B")
        XCTAssertEqual(stateB.encode(to: String.self), "0201010040008000020000044040400001040104402040200000000400000080W")
    }

    func testDecode() {
        let stateA = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1010_1010_0101_0101_1010_1010,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0101_0101_1010_1010_0101_0101_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: true
        )
        let stateAString = "0101010110101010010101010000000000000000404040400404040440404040B"

        let stateB = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0010_0010_0000_0000_0000_0000_0000_0000_0010_1000,
            blackKings: 0b0000_0000_0000_0000_0100_0100_0000_0000_0000_0000_0000_0010_0000_0000_0000_0010,
            whiteMen: 0b0000_0000_1000_0000_0001_0001_1000_1000_0001_0101_1000_0000_0000_0001_0000_0000,
            whiteKings: 0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000,
            blackTurn: false
        )
        let stateBString = "0201010040008000020000044040400001040104402040200000000400000080W"

        XCTAssertNoThrow(try GameState.init(dump: stateAString))
        let parsedStateA = try? GameState.init(dump: stateAString)
        XCTAssertEqual(parsedStateA, stateA)

        XCTAssertNoThrow(try GameState.init(dump: stateBString))
        let parsedStateB = try? GameState.init(dump: stateBString)
        XCTAssertEqual(parsedStateB, stateB)
    }

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
            XCTAssertEqual(
                state.board,
                state.board & GameState.playableSquares
            )
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
                newState!.board.whiteMen.pieces | newState!.board.whiteKings.pieces | newState!.board.blackMen.pieces | newState!.board.blackKings.pieces,
                newState!.board.whiteMen.pieces ^ newState!.board.whiteKings.pieces ^ newState!.board.blackMen.pieces ^ newState!.board.blackKings.pieces,
                "Pieces should not overlap" +
                    CheckersUtils.encode(dump: state) + " -> " + CheckersUtils.encode(dump: newState!))
            XCTAssertEqual(newState!.board & GameState.playableSquares,
                           newState!.board,
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
                newState!.number(of: state.turn.selector()),
                state.number(of: state.turn.selector()),
                "Player should not lose any pieces during his own turn." +
                    CheckersUtils.encode(dump: state) + " -> " + CheckersUtils.encode(dump: newState!))
            XCTAssertLessThanOrEqual(
                newState!.number(of: state.turn.flip().king().selector()),
                state.number(of: state.turn.flip().king().selector()),
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
        // var state=CheckersUtils.decode(dump: "0000000000400040000000000000000000000002001000000000000000000000W")
        var state = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackKings: 0b0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0100_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: false
        )
        var child = state.children.first!
        XCTAssertEqual(child.number(of: .WhiteMen), 1)
        XCTAssertEqual(child.number(of: .WhiteKings), 1)
        XCTAssertEqual(child.number(of: .BlackMen), 1)
        XCTAssertEqual(child.number(of: .BlackKings), 1)

        state = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0100_0000_0000,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0001_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: false)
        child = state.children.first!
        XCTAssertEqual(
            child,
            GameState(
                blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000,
                blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000,
                whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010,
                blackTurn: true))

        // state=PortableDraughtsNotation.decode("B:W25,29:B21,K22")
        state=GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackKings: 0b0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0000_0001_0000_0010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackTurn: true)
        child = state.children.first!
        XCTAssertEqual(child,
                       GameState(
                        blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                        blackKings: 0b0000_0100_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                        whiteMen: 0b0000_0001_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                        whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                        blackTurn: false)
        )
    }

    static var allTests = [
        ("testPiecesShouldStayInDarkSquares", testPiecesShouldStayInDarkSquares),
        ("testPieceCount", testPieceCount)
    ]
}
