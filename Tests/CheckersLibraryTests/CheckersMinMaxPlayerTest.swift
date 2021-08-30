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
        let startStates = [
            "B:W21,22,23,24,25,26,27,28,29,30,31,32:B1,2,3,4,5,6,7,8,9,10,11,12",
            "W:W6,10,K13,16,17,21,25,26,K29,32:BK9,20,22,K24,28",
            "B:WK2,K7,K8,K15,K17,K20,K22,K27,K28,K32:B1,K3,6,11,12,K13,14,16,K23,K30,K31",
            "B:W7,K9,10,12,18,19,K21,27,28,29,32:B1,2,4,5,8,13,14,16,20,22,23,24",
            "W:W5,6,8,9,11,15,21,22,24,28,29,32:B1,2,10,13,16,17,19,20,23,25,26,27",
            "W:WK3,K4,K14,K21,K24,K28,K29,30,K31,K32:BK1,7,K9,10,11,12,13,18,20,K25,K27",
            "B:WK8,10,20,22,23,K24,26,30:B2,3,K6,K7,K9,K12,K14,16,17,18,K19,25"
        ].map {
            // swiftlint:disable:next force_try
            try! GameState.init(fen: $0)
        }
        let maxMovesPerGame = 50
        for startState in startStates {
            let minmax=CheckersMinMax()
            var state: GameState?=startState
            var previousState=startState
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
        XCTAssertGreaterThanOrEqual(minmax.knownValues.count, 100)
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
        let whiteCanForceWinInFourTurns = GameState(
            blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000,
            whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0001_0100_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000,
            blackTurn: false
        )
        let black=CheckersMinMax()
        let white=black
        var blackMove: GameState? = whiteCanForceWinInFourTurns
        var whiteMove: GameState?
        for _ in 0...15 {
            whiteMove = white.provideMove(blackMove!)
            XCTAssertNotNil(
                whiteMove,
                "White player should not lose from a state from which it can force win within searchdepth.")
            guard whiteMove != nil else { break }
            blackMove = black.provideMove(whiteMove!)
            guard blackMove != nil else { break }
        }
        XCTAssertNil(blackMove, "Black player should lose if white player can force win.")
        let blackCanForceWinInFourTurns = PortableDraughtsNotation.decode(
            "B:BK10,K22,K23:WK2")
        whiteMove = blackCanForceWinInFourTurns
        for _ in 0...15 {
            blackMove = black.provideMove(whiteMove!)
            XCTAssertNotNil(
                blackMove,
                "Black player should not lose from a state from which it can force win within searchdepth.")
            guard blackMove != nil else { break }
            whiteMove = white.provideMove(blackMove!)
            guard whiteMove != nil else { break }
        }
        XCTAssertNil(whiteMove, "White player should lose if black player can force win.")
    }
    func testPerformanceProvideMove5() throws {
        let minMax = CheckersMinMax()
        minMax.searchDepth=5
        self.measure {
            _ = minMax.provideMove(GameState.defaultStart)
        }
    }
    func testPerformanceProvideMove7() throws {
        let minMax = CheckersMinMax()
        minMax.searchDepth=7
        self.measure {
            _ = minMax.provideMove(GameState.defaultStart)
        }
    }
    func testPerformanceProvideMove9() throws {
        let minMax = CheckersMinMax()
        minMax.searchDepth=9
        self.measure {
            _ = minMax.provideMove(GameState.defaultStart)
        }
    }
    func testPerformanceProvideMove11() throws {
        let minMax = CheckersMinMax()
        minMax.searchDepth=11
        self.measure {
            _ = minMax.provideMove(GameState.defaultStart)
        }
    }
    func testPerformanceProvideMove13() throws {
        let minMax = CheckersMinMax()
        minMax.searchDepth=13
        self.measure {
            _ = minMax.provideMove(GameState.defaultStart)
        }
    }
    func testPerformanceProvideMove15() throws {
        let minMax = CheckersMinMax()
        minMax.searchDepth=15
        self.measure {
            _ = minMax.provideMove(GameState.defaultStart)
        }
    }

    static var allTests = [
        ("testCache", testCache),
        ("testPerformance", testPerformance),
        ("testProvidesLegalMove", testProvidesLegalMove),
        ("testMinMaxWinsIfWinCanForcedInSearchDepth", testMinMaxWinsIfWinCanForcedInSearchDepth)
    ]
}
