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

    private let gameStateA=GameState(
        blackMen: 0b10,
        blackKings: 0b1000,
        whiteMen: 0,
        whiteKings: 0b100000,
        blackTurn: false)
    private let gamestateB = CheckersUtils.decode(
        dump: "0101010110101010010000001010108000020000000000000404040440404040B")!

    /// Tests if state of the board is parsed correctly from FEN-string.
    func testFentoState() {
        XCTAssertEqual(PortableDraughtsNotation.PDNfenToGameState(fenA), gameStateA)
        XCTAssertEqual(
            gamestateB,
            PortableDraughtsNotation.PDNfenToGameState(
                "B:WK16,25,26,27,28,29,30,31,32:B1,2,3,4,5,6,7,8,9,13,14,15,K18"))
    }
    /// Tests if state of the board is encoded correctly into FEN-string.
    func testStatetoFen() {
        XCTAssertEqual(PortableDraughtsNotation.stateToFen(gameStateA), fenA)
        XCTAssertEqual(
            PortableDraughtsNotation.stateToFen(gamestateB),
            "B:WK16,25,26,27,28,29,30,31,32:B1,2,3,4,5,6,7,8,9,13,14,15,K18")
    }

    func testInternalSquareNotationToPDNSquareNumber() {
        XCTAssertEqual(PortableDraughtsNotation.IntToPDN(1), 1)
        XCTAssertEqual(PortableDraughtsNotation.IntToPDN(62), 32)
    }

    func testPDNSquareNumberToInternalSquareNotation() {
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(1), 1)
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(2), 3)
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(3), 5)
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(4), 7)
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(8), 14)
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(28), 55)
        XCTAssertEqual(PortableDraughtsNotation.PDNToInt(32), 62)
    }

    static var allTests = [
        ("testFentoState", testFentoState),
        ("testStatetoFen", testStatetoFen)
    ]
}
