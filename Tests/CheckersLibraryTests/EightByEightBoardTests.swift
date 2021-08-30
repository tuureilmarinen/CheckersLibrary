//
//  EightByEightBoardTests.swift
//  CheckersLibraryTests
//
//  Created by Tuure Ilmarinen on 30.8.2021.
//

import XCTest
@testable import CheckersLibrary

class EightByEightBoardTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testShift() {
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(1), .Left(1))), -9)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(2), .Left(1))), -17)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(1), .Left(2))), -10)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(2), .Left(2))), -18)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(1), .Right(1))), -7)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(2), .Right(1))), -15)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(1), .Right(2))), -6)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(2), .Right(2))), -14)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(2), .None)), -16)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Up(1), .None)), -8)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(1), .Left(1))), 7)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(2), .Left(1))), 15)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(1), .Left(2))), 6)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(2), .Left(2))), 14)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(1), .Right(1))), 9)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(2), .Right(1))), 17)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(1), .Right(2))), 10)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(2), .Right(2))), 18)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(2), .None)), 16)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.Down(1), .None)), 8)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.None, .Left(1))), -1)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.None, .Left(2))), -2)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.None, .Right(1))), 1)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.None, .Right(2))), 2)
        XCTAssertEqual(EightByEightBoard.shift(Direction(.None, .None)), 0)
    }
    func testTurnInto() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let board = EightByEightBoard(
            blackMen: 0b0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            blackKings: 0b0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
            whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0100_0000_0000,
            whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000
        )
        let moved = board.turn(.WhiteMan, into: .WhiteKing)
        XCTAssertEqual(
            moved,
            EightByEightBoard(
                blackMen: 0b0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                blackKings: 0b0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                whiteMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
                whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0100_0000_0000)
        )
    }

    func testMove() {
        XCTAssertEqual(
            GameState.defaultStart.board.move(.BlackMen, Direction(.Down(1), .Left(1))),
            EightByEightBoard(blackMen: 1428837632, blackKings: 0, whiteMen: 6172839697753047040, whiteKings: 0))
        XCTAssertEqual(
            GameState.defaultStart.board.move(.BlackMen, Direction(.Down(1), .Right(1))),
            EightByEightBoard(blackMen: 1420448768, blackKings: 0, whiteMen: 6172839697753047040, whiteKings: 0))
        XCTAssertEqual(
            EightByEightBoard(blackMen: 1420448768, blackKings: 0, whiteMen: 6172839697753047040, whiteKings: 0).move(.BlackMen, Direction(.Up(1), .Left(1))),
            EightByEightBoard(blackMen: 2774314, blackKings: 0, whiteMen: 6172839697753047040, whiteKings: 0))
        XCTAssertEqual(
            EightByEightBoard(blackMen: 131072, blackKings: 67108864, whiteMen: 2097152, whiteKings: 268435456).move(.BlackKings, Direction(.Up(1), .Right(1))),
            EightByEightBoard(blackMen: 131072, blackKings: 524288, whiteMen: 2097152, whiteKings: 268435456))
        XCTAssertEqual(
            EightByEightBoard(blackMen: 131072, blackKings: 67108864, whiteMen: 2097152, whiteKings: 268435456).move(.BlackKings, Direction(.Up(2), .Right(2))),
            EightByEightBoard(blackMen: 131072, blackKings: 4096, whiteMen: 2097152, whiteKings: 268435456))
        XCTAssertEqual(
            EightByEightBoard(blackMen: 36033238015283464, blackKings: 32, whiteMen: 1152922604126863360, whiteKings: 360305562663518208).move(.At([8, 21]), Direction(.Up(1), .Right(1))),
            EightByEightBoard(blackMen: 36033238015283210, blackKings: 32, whiteMen: 1152922604126863360, whiteKings: 360305562661437440))
        /* XCTAssertEqual(
            EightByEightBoard(blackMen: 0, blackKings: 0, whiteMen: 0, whiteKings: 0).move(.BlackMen,Direction(.Up(1),.Left(1))),
            EightByEightBoard(blackMen: 0, blackKings: 0, whiteMen: 0, whiteKings: 0)) */
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
