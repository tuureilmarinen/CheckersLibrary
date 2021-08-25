//
//  CheckersDeterministicRandomPlayerTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 29.7.2021.
//

import Foundation
import XCTest
@testable import CheckersLibrary

final class CheckersDeterministicRandomPlayerTests: XCTestCase {

    func testSameStatesWithSameSeedGetsSameMove() {
        var sameseedA=CheckersDeterministicRandomPlayer(seed:609)
        var sameseedB=CheckersDeterministicRandomPlayer(seed:609)
        var differentSeed=CheckersDeterministicRandomPlayer(seed:420)
        var gameState = GameState.defaultStart
        var equalResultCounter=0
        var totalCounter=0
        for _ in 0..<100 {
            guard !gameState.children.isEmpty else {
                break
            }
            XCTAssertEqual(sameseedA.provideMove(gameState), sameseedB.provideMove(gameState))
            if gameState.children.count>2 && sameseedA.provideMove(gameState)==differentSeed.provideMove(gameState) {
                equalResultCounter+=1
            }
            totalCounter+=1
            gameState=sameseedA.provideMove(gameState)!
        }

        XCTAssertLessThan(Double(equalResultCounter)/Double(totalCounter), 0.75)

    }
}
