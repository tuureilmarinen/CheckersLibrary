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

    /// TODO
    /// Test that beta-cutoff actually occurs and does not occur when it should not.
    func testAlphaCutoff() {

    }
    /// TODO
    /// Test that beta-cutoff actually occurs and does not occur when it should not.
    func testBetaCutoff() {

    }

    /// The provideMove-method should always return a position that is one move away from the state
    /// ie. it does not return illegal moves.
    func testProvidesLegalMove() {
        let totalGames = 20
        let maxMovesPerGame = 50
        for _ in 0..<totalGames {
            let minmax=CheckersMinMax()
            var state: GameState?=GameState.defaultStart
            var previousState=GameState.defaultStart
            var children: Set<GameState>
            for _ in 0...maxMovesPerGame {
                children=state!.children
                previousState=state!
                state=minmax.provideMove(state!)
                guard state != nil else { break }
                XCTAssert(
                    children.contains(state!),
                    "MinMaxPlayer should provide legal move. " +
                        "Got \(String(describing: state)) from \(previousState)"
                )
            }
        }
    }

    /// Tests cache.
    /// - found values should be stored in cache
    /// - if value is in the cache, it should be returned
    /// - best found move should be the one stored in cache
    func testCache() {
        let minmax=CheckersMinMax()
        var state: GameState?=GameState.defaultStart
        XCTAssertEqual(minmax.knownValues.count, 0)
        let newState=minmax.provideMove(state!)!
        XCTAssertEqual(minmax.guessDepth[state!], minmax.searchDepth)
        state=newState
        XCTAssertGreaterThanOrEqual(minmax.knownValues.count, 500)

        for _ in 0...10 {
            XCTAssertEqual(minmax.provideMove(state!), minmax.optimalKnownMove[state!]!)
            state=minmax.provideMove(state!)
            guard state != nil else { break }
        }
    }
    func testValueOutsideOfAcceptableCacheDepthIsNotReturnedFromCache() {
        let minmax=CheckersMinMax()
        let second = GameState(
            blackMen: 0b0000_0000_0000_0010_0001_0000_1000_0000_0000_0100_0000_0000_0100_0101_0000_1010,
           blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
           whiteMen: 0b0000_0000_1010_0000_0100_0000_0000_0000_0000_0001_0010_0000_0001_0000_0000_0000,
           whiteKings: 0b0001_0001_0000_0000_0000_0000_0010_1000_0000_0000_1000_0000_0000_0000_1000_0000,
           blackTurn: true)
        let third = GameState(
            blackMen: 0b0000_0000_0000_1000_0000_0101_0000_1000_0101_0000_0000_0010_0000_0101_1010_1000,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0100_0000_0000_0000_0000_0000_0010_0000_0000_0100_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0100_0000_0010_0101_0000_0000_0010_0000_0001_1010_0000_0001_0000_0000_0000,
            blackTurn: false)
        minmax.cacheDepth=10
        minmax.knownValues[second] = Double.infinity
        minmax.optimalKnownMove[second] = third
        minmax.guessDepth[second]=3
        XCTAssertNotEqual(minmax.provideMove(second)!, third)
    }
    func testValueWithinAcceptableCacheDepthIsReturnedFromCache() {
        let minmax=CheckersMinMax()
        let first = GameState(
            blackMen: 0b0000_0000_0010_1000_0101_0100_0010_0000_0101_0100_0000_0010_0000_0000_1000_0010,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000,
            whiteKings: 0b0000_0101_1000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000,
            blackTurn: true)
        let second = GameState(
            blackMen: 0b0000_0000_0000_0010_0001_0000_1000_0000_0000_0100_0000_0000_0100_0101_0000_1010,
           blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
           whiteMen: 0b0000_0000_1010_0000_0100_0000_0000_0000_0000_0001_0010_0000_0001_0000_0000_0000,
           whiteKings: 0b0001_0001_0000_0000_0000_0000_0010_1000_0000_0000_1000_0000_0000_0000_1000_0000,
           blackTurn: true)
        minmax.knownValues[first] = -Double.infinity
        minmax.optimalKnownMove[first] = second
        minmax.guessDepth[first]=9001
        XCTAssertEqual(minmax.provideMove(first)!, second)

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
            XCTAssertNotNil(
                whiteMove,
                "White player should not lose from a state from which it can force win within searchdepth.")
            blackMove = black.provideMove(whiteMove!)
            guard blackMove != nil else { break }
        }
        XCTAssertNil(blackMove, "Black player should lose if white player can force win.")
        let blackCanForceWinInFourTurns = PortableDraughtsNotation.PDNfenToGameState(
            "B:BK10,K22,K23:WK2")
        whiteMove = blackCanForceWinInFourTurns
        for _ in 0...15 {
            blackMove = black.provideMove(whiteMove!)
            XCTAssertNotNil(
                blackMove,
                "Black player should not lose from a state from which it can force win within searchdepth.")
            whiteMove = white.provideMove(blackMove!)
            guard whiteMove != nil else { break }
        }
        XCTAssertNil(whiteMove, "White player should lose if black player can force win.")
    }

    static var allTests = [
        ("testCache", testCache),
        ("testPerformance", testPerformance),
        ("testProvidesLegalMove", testProvidesLegalMove),
        ("testMinMaxWinsIfWinCanForcedInSearchDepth", testMinMaxWinsIfWinCanForcedInSearchDepth)
    ]
}
