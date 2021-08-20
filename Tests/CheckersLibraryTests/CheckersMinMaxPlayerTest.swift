//
//  CheckersUtilsTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class CheckersMinMaxPlayerTests: XCTestCase {

    /// Tests that the MinMax-algorithm preforms significantly better than a player making completely random moves.
    /// MinMaxPlayer should win at least 80% percent of games.
    func testPerformance() {
        var lostGames=0
        let totalGames=20
        let maxMovesPerGame=50
        for _ in 0..<totalGames {
            let rand=CheckersRandomPlayer()
            let minmax=CheckersMinMax()
            var state: GameState?=GameState.defaultStart

            for _ in 0...maxMovesPerGame {
                state=minmax.provideMove(state!)
                guard state != nil else {
                    lostGames+=1
                    break
                }
                state=rand.provideMove(state!)
                guard state != nil else { break }

            }
        }
        XCTAssertLessThan(
            Double(lostGames)/Double(totalGames),
            0.2,
            "Player should not lose more than 20% of games against a player making random moves.")
    }

    /// The provideMove-method should always return a position that is one move away from the state
    /// ie. it does not return illegal moves.
    func testProvidesLegalMove() {
        let totalGames = 20
        let maxMovesPerGame = 50
        for _ in 0..<totalGames {
            let minmax=CheckersMinMax()
            var state: GameState?=GameState.defaultStart
            var children: Set<GameState>
            for _ in 0...maxMovesPerGame {
                children=state!.children
                state=minmax.provideMove(state!)
                guard state != nil else { break }
                XCTAssert(
                    children.contains(state!),
                    "MinMaxPlayer should provide legal move.")
            }
        }
    }

    /// Tests wheter player wins from state from which it can force win.
    func testMinMaxWinsIfWinCanForcedInSearchDepth() {
        let whiteCanForceWinInFourTurns = PortableDraughtsNotation.PDNfenToGameState(
            "W:BK2:WK10,K22,K23")
        let black=CheckersMinMax()
        let white=black
        var blackMove: GameState? = whiteCanForceWinInFourTurns
        var whiteMove: GameState?
        for _ in 0...15 {
            whiteMove = white.provideMove(blackMove!)
            XCTAssertNotNil(whiteMove, "White player should not lose from a state from which it can force win within searchdepth.")
            blackMove = black.provideMove(whiteMove!)
            guard blackMove != nil else { break }
        }
        XCTAssertNil(blackMove, "Black player should lose if white player can force win.")
    }

    static var allTests = [
        ("testPerformance", testPerformance),
        ("testProvidesLegalMove", testProvidesLegalMove),
        ("testMinMaxWinsIfWinCanForcedInSearchDepth", testMinMaxWinsIfWinCanForcedInSearchDepth)
    ]
}
