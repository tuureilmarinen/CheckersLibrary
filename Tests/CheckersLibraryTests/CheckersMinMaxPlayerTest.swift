//
//  CheckersUtilsTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class CheckersMinMaxPlayerTests: XCTestCase {

    func testPerformance() {
        var lostGames=0
        let totalGames=20
        for _ in 0..<totalGames {
            let rand=CheckersRandomPlayer()
            let minmax=CheckersMinMax()
            var state: GameState?=GameState.defaultStart

            repeat {
                state=minmax.provideMove(state!)
                guard state != nil else {
                    lostGames+=1
                    break
                }
                state=rand.provideMove(state!)
            } while state != nil
        }
        XCTAssertLessThan(
            Double(lostGames)/Double(totalGames),
            0.2,
            "Player should not lose more than 20% of games against a player making random moves.")
    }

    static var allTests = [
        ("testPerformance", testPerformance)
    ]
}
