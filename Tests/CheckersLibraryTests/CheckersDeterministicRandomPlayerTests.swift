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
        var sameseedA=CheckersDeterministicRandomPlayer()
        var sameseedB=CheckersDeterministicRandomPlayer()
        var differentSeed=CheckersDeterministicRandomPlayer()
        differentSeed.seed=UInt64.max/2
        sameseedA.seed=9001
        sameseedB.seed=sameseedA.seed
        var gameState = GameState.defaultStart
        var equalResultCounter=0
        var totalCounter=0
        for _ in 0..<100 {
            guard !gameState.children.isEmpty else {
                break
            }
            XCTAssertEqual(sameseedA.provideMove(gameState), sameseedB.provideMove(gameState))
            if gameState.children.count>1 && sameseedA.provideMove(gameState)==differentSeed.provideMove(gameState) {
                equalResultCounter+=1
            }
            totalCounter+=1
            gameState=sameseedA.provideMove(gameState)!
        }
        
        XCTAssertLessThan(Double(equalResultCounter)/Double(totalCounter), 0.5)
        
    }
}
