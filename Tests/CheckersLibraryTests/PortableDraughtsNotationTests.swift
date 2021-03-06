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

    private let gamestateB = GameState(
        blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0001_0101_0000_0010_0101_0101_1010_1010,
        blackKings: 0b0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000,
        whiteMen: 0b0101_0101_1010_1010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
        whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000,
        blackTurn: true
    )

    let gamestateC = GameState(
        blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
        blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000,
        whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
        whiteKings: 0b0000_0000_0000_0000_0001_0100_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000,
        blackTurn: false
    )
    let fenCa = "W:WK10,K22,K23:BK2"
    let fenCb = "W:BK2:WK10,K22,K23"

    /// Tests if state of the board is parsed correctly from FEN-string.
    func testFentoState() {
        XCTAssertEqual(PortableDraughtsNotation.decode(fenA), gameStateA)
        XCTAssertEqual(
            gamestateB,
            PortableDraughtsNotation.decode(
                "B:WK16,25,26,27,28,29,30,31,32:B1,2,3,4,5,6,7,8,9,13,14,15,K18"))
        XCTAssertNoThrow(try GameState(fen: fenCa))
        XCTAssertNoThrow(try GameState(fen: fenCb))
        XCTAssertEqual(try? GameState(fen: fenCa), gamestateC)
        XCTAssertEqual(try? GameState(fen: fenCb), gamestateC)
    }
    /// Tests if state of the board is encoded correctly into FEN-string.
    func testStatetoFen() {
        XCTAssertEqual(PortableDraughtsNotation.encode(gameStateA), fenA)
        XCTAssertEqual(
            PortableDraughtsNotation.encode(gamestateB),
            "B:WK16,25,26,27,28,29,30,31,32:B1,2,3,4,5,6,7,8,9,13,14,15,K18")
        XCTAssertEqual(gamestateC.encode(to: PortableDraughtsNotation.self), fenCa)
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
