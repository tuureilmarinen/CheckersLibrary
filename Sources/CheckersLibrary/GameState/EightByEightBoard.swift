//
//  EightByEightBoard.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 25.8.2021.
//

import Foundation

struct EightByEightBoard: Hashable, Codable, Identifiable {
    var id: String {
        "\(blackMen):\(whiteMen):\(blackKings):\(whiteKings)"
    }
    public var blackMen: UInt64=0
    public var whiteMen: UInt64=0
    public var blackKings: UInt64=0
    public var whiteKings: UInt64=0

    func copySetting(
        blackMen: UInt64? = nil,
        whiteMen: UInt64? = nil,
        blackKings: UInt64? = nil,
        whiteKings: UInt64? = nil) -> EightByEightBoard {
        return EightByEightBoard(
            blackMen: blackMen ?? self.blackMen,
            whiteMen: whiteMen ?? self.whiteMen, blackKings: blackKings ?? self.blackKings,
            whiteKings: whiteKings ?? self.whiteKings
        )
    }

    /* 0b1111_1111
        _1000_0001
        _1000_0001
        _1000_0001
        _1000_0001
        _1000_0001
        _1000_0001
        _1111_1111 */
    public static let edges: UInt64 = 18411139144890810879

    /// ~edges
    public static let notEdges: UInt64 = 35604928818740736

    /* 0b
    / 1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000 */
    public static let rightEdge: UInt64 = 9259542123273814144

    /* 0b
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001 */
    public static let leftEdge: UInt64 = 72340172838076673

    // 0b1111_1111_0000...
    public static let whiteEnd: UInt64 = 18374686479671623680

    /// 0b0000_0000_0000_.......1111_1111
    public static let blackEnd: UInt64 = 255

    /// 0b0101_0101_1010_1010_0101_0101_1010_1010_0101_0101_1010_1010_0101_0101_1010_1010
    public static let darkSquares: UInt64 = 6172840429334713770
    /* 0b
        0101_0101_
        1010_1010_
        0101_0101_
        1010_1010_
        0101_0101_
        1010_1010_
        0101_0101_
        1010_1010 */

    /// ~darkSquares
    static let whiteSquares: UInt64 = 12273903644374837845
}
