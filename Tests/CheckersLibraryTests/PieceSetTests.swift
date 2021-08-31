//
//  PieceSetTests.swift
//  CheckersLibraryTests
//
//  Created by Tuure Ilmarinen on 30.8.2021.
//

import XCTest
@testable import CheckersLibrary

class PieceSetTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIndexes() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(PieceSet(0b101010).indexes, [1, 3, 5])
        XCTAssertEqual(PieceSet(0b100101010).indexes, [1, 3, 5, 8])
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
