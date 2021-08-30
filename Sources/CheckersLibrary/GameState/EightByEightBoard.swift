//
//  EightByEightBoard.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 25.8.2021.
//

import Foundation

public struct EightByEightBoard: Equatable, Hashable, Codable, Identifiable, CustomStringConvertible {

    public var blackMen: PieceSet = PieceSet(0)
    public var blackKings: PieceSet = PieceSet(0)
    public var whiteMen: PieceSet = PieceSet(0)
    public var whiteKings: PieceSet = PieceSet(0)
    public var suit: [CheckersPiece: PieceSet] {
        return [
            .BlackMan: blackMen,
            .BlackKing: blackKings,
            .WhiteMan: whiteMen,
            .WhiteKing: whiteKings
        ]
    }

    public init(blackMen: UInt64 = 0, blackKings: UInt64 = 0, whiteMen: UInt64 = 0, whiteKings: UInt64 = 0) {
        self.blackMen = PieceSet(blackMen)
        self.blackKings = PieceSet(blackKings)
        self.whiteMen = PieceSet(whiteMen)
        self.whiteKings = PieceSet(whiteKings)
    }

    public init(
        blackMen: PieceSet = PieceSet(0),
        blackKings: PieceSet = PieceSet(0),
        whiteMen: PieceSet = PieceSet(0),
        whiteKings: PieceSet = PieceSet(0)
    ) {
        self.blackMen = blackMen
        self.blackKings = blackKings
        self.whiteMen = whiteMen
        self.whiteKings = whiteKings
    }

    public var id: String {
        "\(blackMen):\(whiteMen):\(blackKings):\(whiteKings)"
    }

    public var description: String { return "EightByEightBoard: \(encode(to: String.self))" }

    func copyWith(
        blackMen: PieceSet? = nil,
        blackKings: PieceSet? = nil,
        whiteMen: PieceSet? = nil,
        whiteKings: PieceSet? = nil) -> EightByEightBoard {
        return EightByEightBoard(
            blackMen: blackMen ?? self.blackMen,
            blackKings: blackKings ?? self.blackKings,
            whiteMen: whiteMen ?? self.whiteMen,
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
    public static let edges: PieceSet = PieceSet(18411139144890810879)

    /// ~edges
    public static let notEdges: PieceSet = PieceSet(35604928818740736)

    /* 0b
    / 1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000_
    1000_0000 */
    public static let rightEdge: PieceSet = PieceSet(9259542123273814144)

    /* 0b
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001_
     0000_0001 */
    public static let leftEdge: PieceSet = PieceSet(72340172838076673)

    // 0b1111_1111_0000...
    public static let whiteEnd: PieceSet = PieceSet(18374686479671623680)

    /// 0b0000_0000_0000_.......1111_1111
    public static let blackEnd: PieceSet = PieceSet(255)

    /// 0b0101_0101_1010_1010_0101_0101_1010_1010_0101_0101_1010_1010_0101_0101_1010_1010
    public static let darkSquares: PieceSet = PieceSet(6172840429334713770)
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
    static let whiteSquares: PieceSet = PieceSet(12273903644374837845)

    // A computed property of all black pieces on the board.
    var blackPieces: PieceSet {
        return blackMen | blackKings
    }

    // A computed property of all black pieces on the board.
    var whitePieces: PieceSet {
        return whiteMen | whiteKings
    }

    // A computed property of all pieces on the board.
    var allPieces: PieceSet {
        return whiteMen | whiteKings | blackMen | blackKings
    }

    public func turn (_ pieces: CheckersPiece, into: CheckersPiece, at: PieceSet) -> EightByEightBoard {
        return self.turn(pieces, into: into, at: at.indexes)
    }

    public func turn(_ pieces: CheckersPiece, into: CheckersPiece, at: [Int]?=nil) -> EightByEightBoard {
        let onlyThesePieces: PieceSet = at != nil ? PieceSet(at!) : PieceSet(UInt64.max)
        var st=self
        // let onlyThesePieces = PieceSet(at)
        let piecesToMove = st[pieces] & onlyThesePieces
        st[pieces] = st[pieces] & (~piecesToMove)
        // st[pieces] = st[pieces] & (~self.pieces(.At(at.indexes)))
        st[into] = st[into] | piecesToMove
        return st
    }

    public func pieces(_ selection: CheckersPieceSelector, except: CheckersPieceSelector? = nil) -> PieceSet {
        guard except == nil else {
            return pieces(selection) & ~pieces(except!)
        }
        switch selection {
        case .All:
            return self.allPieces
        case .Black:
            return self.blackPieces
        case .White:
            return self.whitePieces
        case .WhiteMen:
            return self.whiteMen
        case .WhiteKings:
            return self.whiteKings
        case .BlackMen:
            return self.blackMen
        case .BlackKings:
            return self.blackKings
        case .Empty:
            return ~self.allPieces // & GameState.playableSquares
        case .At(let indexes):
            return self.allPieces & PieceSet(indexes)
        }
    }
    private static func shift(_ v: UpDown) -> Int {
        switch v {
        case .Up(let u):
            return (-8)*u
        case .Down(let d):
            return 8*d
        default:
            return 0
        }
    }
    private static func shift(_ h: LeftRight) -> Int {
        switch h {
        case .Left(let l):
            return (-1)*l
        case .Right(let r):
            return r
        default:
            return 0
        }
    }
    public static func shift(_ d: Direction) -> Int {
        return shift(d.horizontal) + shift(d.vertical)
    }

    public func remove(at direction: Direction, from: PieceSet) -> EightByEightBoard {
        let at=from<<EightByEightBoard.shift(direction)
        return EightByEightBoard(
            blackMen: blackMen&(~at),
            blackKings: blackKings&(~at),
            whiteMen: whiteMen&(~at),
            whiteKings: whiteKings&(~at))
    }

    public func remove(at: PieceSet) -> EightByEightBoard {
        return EightByEightBoard(
            blackMen: blackMen&(~at),
            blackKings: blackKings&(~at),
            whiteMen: whiteMen&(~at),
            whiteKings: whiteKings&(~at))
    }

    public func move(back selection: CheckersPieceSelector, _ direction: Direction) -> EightByEightBoard {
        let flippedDirection = direction.flip()
        return move(selection, flippedDirection)
    }
    private static func edgeFilter(_ direction: Direction) -> PieceSet {
        switch direction.horizontal {
        case .Left(_):
            return ~EightByEightBoard.leftEdge
        case .Right(_):
            return ~EightByEightBoard.rightEdge
        case .None:
            return PieceSet(0)
        }
    }
    public func move(_ selection: CheckersPieceSelector, _ direction: Direction) -> EightByEightBoard {
        let edgeFilter = EightByEightBoard.edgeFilter(direction)
        let shift = EightByEightBoard.shift(direction)
        switch selection {
        case .Black:
            return copyWith(
                blackMen: (blackMen&edgeFilter)<<shift,
                blackKings: (blackKings&edgeFilter)<<shift)
        case .White:
            return copyWith(
                whiteMen: (whiteMen&edgeFilter)<<shift,
                whiteKings: (whiteKings&edgeFilter)<<shift)
        case .WhiteMen:
            return copyWith(
                whiteMen: (whiteMen&edgeFilter)<<shift)
        case .WhiteKings:
            return copyWith(
                whiteKings: (whiteKings&edgeFilter)<<shift
            )
        case .BlackMen:
            return copyWith(
                blackMen: (blackMen&edgeFilter)<<shift
            )
        case .BlackKings:
            return copyWith(
                blackKings: (blackKings&edgeFilter)<<shift
            )
        case .All:
            return copyWith(
                blackMen: (blackMen&edgeFilter)<<shift,
                blackKings: (blackKings&edgeFilter)<<shift,
                whiteMen: (whiteMen&edgeFilter)<<shift,
                whiteKings: (whiteKings&edgeFilter)<<shift
            )
        case .Empty:
            return self
        case .At(let values):
            let bm = ((blackMen & PieceSet(values) & edgeFilter) << shift) | (blackMen.and(not: PieceSet(values)))
            let bk = ((blackKings & PieceSet(values) & edgeFilter) << shift) | (blackKings.and(not: PieceSet(values)))
            let wm = ((whiteMen & PieceSet(values) & edgeFilter) << shift) | (whiteMen.and(not: PieceSet(values)))
            let wk = ((whiteKings & PieceSet(values) & edgeFilter) << shift) | (whiteKings.and(not: PieceSet(values)))
            return EightByEightBoard(blackMen: bm, blackKings: bk, whiteMen: wm, whiteKings: wk)
        }
    }
    static func & (left: EightByEightBoard, right: PieceSet) -> EightByEightBoard {
        return EightByEightBoard(
            blackMen: left.blackMen&right,
            blackKings: left.blackKings&right,
            whiteMen: left.whiteMen&right,
            whiteKings: left.whiteKings&right
        )
    }
    subscript(index: CheckersPiece) -> PieceSet {
        get {
            switch index {
            case .BlackMan:
                return self.blackMen
            case .BlackKing:
                return self.blackKings
            case .WhiteMan:
                return self.whiteMen
            case .WhiteKing:
                return self.whiteKings
            }
        }
        set(newValue) {
            switch index {
            case .BlackMan:
                self.blackMen=newValue
            case .BlackKing:
                self.blackKings=newValue
            case .WhiteMan:
                self.whiteMen=newValue
            case .WhiteKing:
                self.whiteKings=newValue
            }
        }
    }
}
