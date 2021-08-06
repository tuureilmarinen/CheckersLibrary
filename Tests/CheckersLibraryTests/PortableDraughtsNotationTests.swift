//
//  PortableDraughtsNotationTests.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 30.7.2021.
//

import XCTest
@testable import CheckersLibrary

final class PortableDraughtsNotationTests: XCTestCase {

    private let fenA="W:WK3:B1,K2"
    private let fenAa="W:B1,K2:WK3"

    private let gameStateA=GameState(blackMen: 0b10, blackKings: 0b1000, whiteMen: 0, whiteKings: 0b100000, blackTurn: false)

    func testFentoState() {
        XCTAssertEqual(PortableDraughtsNotation.PDNfenToGameState(fenA), gameStateA)
        XCTAssertEqual(PortableDraughtsNotation.stateToFen(gameStateA), fenA)

    }

    static var allTests = [
        ("testFentoState", testFentoState)
    ]
}
