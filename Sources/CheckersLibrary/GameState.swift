//
//  GameState.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 23.7.2021.
//

import Foundation

public enum CheckersPiece: Int {
    case BlackMan = 1
    case BlackKing = 2
    case WhiteMan = 3
    case WhiteKing = 4

    func color (_ color: CheckersColor) -> Bool {
        return (self.rawValue<3 && color == .Black) || (self.rawValue>2 && color == .White)
    }
}

public enum CheckersColor {
    case Black
    case White
    func flip() -> CheckersColor {
        return self == .Black ? .White : .Black
    }
}

public enum CheckersPieceSelector: Int {
    case Black = 6
    case White = 7
    case WhiteMen = 3
    case WhiteKings = 4
    case BlackMen = 1
    case BlackKings = 2
    case All = 8
    case Empty = 5
}

enum CheckersMoveDiff: Int {
    case DownLeft = 7
    case DownRight = 9
    case UpRight = -7
    case UpLeft = -9
    case Nothing = 0
}

struct CheckersCaptureDiff {
    static let DownLeft = (7, 7)
    static let DownRight = (9, 9)
    static let UpLeft = (-9, -9)
    static let UpRight = (-7, -7)
}

enum UpDown: Int {
    case up = -1
    case down = 1
}

enum CaptureDirection {
    case left(UpDown)
    case right(UpDown)
}

enum MoveDirection {
    case left(UpDown)
    case right(UpDown)
}

enum KingsMen {
    case Kings
    case Men
}

let legalJumpDirections: [CheckersPiece: [(Int, Int)]] = [
    .BlackMan: [CheckersCaptureDiff.DownLeft, CheckersCaptureDiff.DownRight],
    .WhiteMan: [CheckersCaptureDiff.UpLeft, CheckersCaptureDiff.UpRight],
    .BlackKing: [
        CheckersCaptureDiff.DownLeft,
        CheckersCaptureDiff.DownRight,
        CheckersCaptureDiff.UpLeft,
        CheckersCaptureDiff.UpRight],
    .WhiteKing: [
        CheckersCaptureDiff.DownLeft,
        CheckersCaptureDiff.DownRight,
        CheckersCaptureDiff.UpLeft,
        CheckersCaptureDiff.UpRight]
]

let CheckersDiff = (move: (
                        down: (
                            left: CheckersMoveDiff.DownLeft,
                            right: CheckersMoveDiff.DownRight),
                        up: (
                            left: CheckersMoveDiff.UpLeft,
                            right: CheckersMoveDiff.UpRight)),
                    capture: (
                        down: (
                            left: CheckersCaptureDiff.DownLeft,
                            right: CheckersCaptureDiff.DownRight),
                        up: (
                            left: CheckersCaptureDiff.UpLeft,
                            right: CheckersCaptureDiff.UpRight)))

/// GameState contains state of the board.
/// It provides a way to get all legal moves from certain state.
public struct GameState: Hashable, Codable, CustomStringConvertible, Identifiable {
    /// The state of the board is represented by a bitboard.
    /// Bit at the least significant position represents square at the leftmost square on the topmost square.
    /// - Parameters:
    ///   - blackMen: Bitboard of the black men on the board.
    ///   - blackKings: Bitboard of the black men on the board.
    ///   - whiteMen: Bitboard of the black men on the board.
    ///   - whiteKings: Bitboard of the black men on the board.
    ///   - blackTurn: True, if the player with the black pieces should make the next move.
    public init(blackMen: UInt64, blackKings: UInt64, whiteMen: UInt64, whiteKings: UInt64, blackTurn: Bool) {
        board=EightByEightBoard(blackMen: blackMen, whiteMen: whiteMen, blackKings: blackKings, whiteKings: whiteKings)
        self.blackTurn=blackTurn
    }

    private var board: EightByEightBoard
    public var blackMen: UInt64 {
        get {
            return board.blackMen
        }
        set(value) {
            board.blackMen=value
        }
    }

    public var blackKings: UInt64 {
        get {
            return board.blackKings
        }
        set(value) {
            board.blackKings=value
        }
    }

    public var whiteMen: UInt64 {
        get {
            return board.whiteMen
        }
        set(value) {
            board.whiteMen=value
        }
    }
    public var whiteKings: UInt64 {
        get {
            return board.whiteKings
        }
        set(value) {
            board.whiteKings=value
        }
    }

    public var id: String {
        return CheckersUtils.encode(dump: self)
    }

    public var description: String { return "GameState: \(CheckersUtils.encode(dump: self))" }

    public var valid: Bool {
        return whiteMen & whiteKings == 0 &&
        whiteMen & blackMen == 0 &&
        whiteMen & blackKings == 0 &&
        blackMen & blackKings == 0 &&
        blackMen & whiteKings == 0 &&
        blackKings & whiteKings == 0 &&
        (whiteMen | whiteKings | blackMen | blackKings) & ~GameState.playableSquares == 0 &&
        blackMen & EightByEightBoard.whiteEnd == 0 &&
            whiteMen & EightByEightBoard.blackEnd == 0
    }

    /// ie. dark squares
    public static var playableSquares: UInt64 {
        return EightByEightBoard.darkSquares
    }

    /// Default starting position.
    /// Both players have 12 pieces located on the dark squares closest to player's own side.
    /// Black moves first.
    public static let defaultStart = GameState(
        blackMen: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1010_1010_0101_0101_1010_1010,
        blackKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
        whiteMen: 0b0101_0101_1010_1010_0101_0101_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
        whiteKings: 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000,
        blackTurn: true
    )

    public func pieces(_ selection: CheckersPieceSelector, _ except: CheckersPieceSelector? = nil) -> UInt64 {
        guard except == nil else {
            return pieces(selection) & ~pieces(except!)
        }
        switch selection {
        case .All:
            return self.allPieces
        case .Black:
            return self.blackPieces
        case .White:
            return whitePieces
        case .WhiteMen:
            return whiteMen
        case .WhiteKings:
            return whiteKings
        case .BlackMen:
            return blackMen
        case .BlackKings:
            return blackKings
        case .Empty:
            return ~allPieces & GameState.playableSquares        }
    }

    public func piece(at: Int) -> CheckersPiece? {
        if (blackMen>>at & 1) == 1 {
            return CheckersPiece.BlackMan
        } else if (blackKings>>at & 1) == 1 {
            return CheckersPiece.BlackKing
        } else if (whiteKings>>at & 1) == 1 {
            return CheckersPiece.WhiteKing
        } else if (whiteMen>>at & 1) == 1 {
            return CheckersPiece.WhiteMan
        } else {
            return nil
        }
    }

    // A computed property of all black pieces on the board.
    var blackPieces: UInt64 {
        return blackMen | blackKings
    }

    // A computed property of all black pieces on the board.
    var whitePieces: UInt64 {
        return whiteMen | whiteKings
    }

    // A computed property of all pieces on the board.
    var allPieces: UInt64 {
        return whiteMen | whiteKings | blackMen | blackKings
    }

    // Wheter the black should make the next turn.
    var blackTurn: Bool

    // Wheter the white should make the next turn.
    var whiteTurn: Bool {
        get {
            return !blackTurn
        }
        set(newWhiteTurnValue) {
            blackTurn = !newWhiteTurnValue
        }
    }

    /// The information about who should make the next turn.
    public var turn: CheckersColor {
        get {
        return self.blackTurn ? CheckersColor.Black : CheckersColor.White
        }
        set (value) {
            self.blackTurn = value == .Black
        }
    }

    /// Contains all legal states the current turn can lead to.
    /// Property is calculated.
    /// Complexity is O(n), where n is number of pieces which are able to move or capture.
    /// Pieces that are unable to move do not affect the complexity.
    ///
    /// The possible moves are calculated simultaneously as all pieces of the same type are stored in single variable.
    /// Movable pieces are determined by
    /// - ANDing them with not edge depending on the intented move direction
    /// - shifting bits in variable to left or right by 7 or 9
    /// - preforming AND operation on NOT allPieces.
    /// Result has a mask of pieces that can move in specified direction.
    /// For each set bit a new state is created moving that specific piece.
    /// Complexity of moving pieces is O(n), where n is the count of set bits.
    /// Captures are determined in a similar way as the moves, except
    ///  - AND operation is instead preformed on opponentPieces instead of not allPieces
    ///  - AND-operation is preformed with notEdges.
    ///  - After that bits are shifted in same direction and by same offset as in the first step.
    ///  - Result has a mask of pieces that can capture pieces in that direction,
    ///    which is then iterated in O(n) time, whre n is number of set bits.
    /// Piece is then checked, if it can preform another capture in O(a^b) time,
    /// where a is average count of directions in which piece can keep jumping.
    /// For kings: 0 <= a <= 3. For men 0<=a<=2. 0<b<16. However a and b are usually low 0 or 1.
    public var children: Set<GameState> {
        var children: Set<GameState> = []
        var mask: UInt64
        if blackTurn {
            // BlackMen Capture
            mask = getCaptureMask(blackMen, blackKings|whitePieces, whitePieces, CheckersDiff.capture.down.left)
            capturePieces(.BlackMan, mask, CheckersDiff.capture.down.left, &children)

            mask = getCaptureMask(blackMen, blackKings|whitePieces, whitePieces, CheckersDiff.capture.down.right)
            capturePieces(.BlackMan, mask, CheckersDiff.capture.down.right, &children)

            if blackKings>0 {
                // Black Kings Capture
                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.down.left)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.down.left, &children)

                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.down.right)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.down.right, &children)

                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.up.left)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.up.left, &children)

                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.up.right)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.up.right, &children)
            }

            guard children.isEmpty else { return children }

            // Black Men Move
            mask = getMoveMask(blackMen & ~EightByEightBoard.leftEdge, allPieces, CheckersDiff.move.down.left)
            movePieces(.BlackMan, mask, CheckersDiff.move.down.left, &children)

            mask = getMoveMask(blackMen & ~EightByEightBoard.rightEdge, allPieces, CheckersDiff.move.down.right)
            movePieces(.BlackMan, mask, CheckersDiff.move.down.right, &children)

            if blackKings>0 {
                // Black Kings Move
                mask=getMoveMask(blackKings & ~EightByEightBoard.leftEdge, allPieces, CheckersDiff.move.down.left)
                movePieces(.BlackKing, mask, CheckersDiff.move.down.left, &children)

                mask=getMoveMask(blackKings & ~EightByEightBoard.rightEdge, allPieces, CheckersDiff.move.down.right)
                movePieces(.BlackKing, mask, CheckersDiff.move.down.right, &children)

                mask=getMoveMask(blackKings & ~EightByEightBoard.leftEdge, allPieces, CheckersDiff.move.up.left)
                movePieces(.BlackKing, mask, CheckersDiff.move.up.left, &children)

                mask=getMoveMask(blackKings & ~EightByEightBoard.rightEdge, allPieces, CheckersDiff.move.up.right)
                movePieces(.BlackKing, mask, CheckersDiff.move.up.right, &children)
            }
        } else { // white Turn
            // White Men Capture
            mask = getCaptureMask(whiteMen, whiteKings|blackPieces, blackPieces, CheckersDiff.capture.up.left)
            capturePieces(.WhiteMan, mask, CheckersDiff.capture.up.left, &children)

            mask = getCaptureMask(whiteMen, whiteKings|blackPieces, blackPieces, CheckersDiff.capture.up.right)
            capturePieces(.WhiteMan, mask, CheckersDiff.capture.up.right, &children)

            if whiteKings>0 {
                // White Kings Capture
                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.down.left)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.down.left, &children)

                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.down.right)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.down.right, &children)

                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.up.left)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.up.left, &children)

                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.up.right)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.up.right, &children)
            }

            guard children.isEmpty else { return children }

            // White Men Move
            mask = getMoveMask(whiteMen & ~EightByEightBoard.leftEdge, allPieces, CheckersDiff.move.up.left)
            movePieces(.WhiteMan, mask, CheckersDiff.move.up.left, &children)
            mask = getMoveMask(whiteMen & ~EightByEightBoard.rightEdge, allPieces, CheckersDiff.move.up.right)
            movePieces(.WhiteMan, mask, CheckersDiff.move.up.right, &children)

            if whiteKings>0 {
                // White Kings Move
                mask = getMoveMask(whiteKings & ~EightByEightBoard.leftEdge, allPieces, CheckersDiff.move.down.left)
                movePieces(.WhiteKing, mask, CheckersDiff.move.down.left, &children)

                mask = getMoveMask(whiteKings & ~EightByEightBoard.rightEdge, allPieces, CheckersDiff.move.down.right)
                movePieces(.WhiteKing, mask, CheckersDiff.move.down.right, &children)

                mask = getMoveMask(whiteKings & ~EightByEightBoard.leftEdge, allPieces, CheckersDiff.move.up.left)
                movePieces(.WhiteKing, mask, CheckersDiff.move.up.left, &children)

                mask = getMoveMask(whiteKings & ~EightByEightBoard.rightEdge, allPieces, CheckersDiff.move.up.right)
                movePieces(.WhiteKing, mask, CheckersDiff.move.up.right, &children)
            }
        }
        return children
    }

    public func number(of: CheckersPieceSelector) -> Int {
        switch of {
        case .BlackMen:
            return blackMen.nonzeroBitCount
        case .BlackKings:
            return blackKings.nonzeroBitCount
        case .WhiteMen:
            return whiteMen.nonzeroBitCount
        case .WhiteKings:
            return whiteKings.nonzeroBitCount
        case .Black:
            return blackPieces.nonzeroBitCount
        case .White:
            return whitePieces.nonzeroBitCount
        case .All:
            return allPieces.nonzeroBitCount
        case .Empty:
            return (GameState.playableSquares & ~blackMen & ~whiteMen & ~blackKings & ~whiteKings).nonzeroBitCount
        }
    }

    /// Provides mask of pieces of certain type that can move to certain direction.
    /// - Parameters:
    ///   - movablePieces: the pieces that are moved. Only one type of pieces can be provided.
    ///   - nonMovablePieces: all other pieces.
    ///   Eg. if movablePieces is blackMen, nonMovablePieces is blackKings|whitePieces
    ///   - direction: the direction in which move is made.
    /// - Returns: Mask of pieces that can be moved to specified direction.
    func getMoveMask(_ movablePieces: UInt64, _ nonMovablePieces: UInt64, _ direction: CheckersMoveDiff) -> UInt64 {
        let diff=direction.rawValue
        return (movablePieces<<diff & (~(((movablePieces|nonMovablePieces)))))>>diff
    }

    /// Provides mask of the movable pieces that can capture one of the capturable pieces
    /// and then land to a unoccupied square.
    /// - Parameters:
    ///   - movablePieces: Bitboard of movable pieces.
    ///   - nonCapturablePieces: the pieces that cannot be captured nor moved.
    ///   Usually the kings of same color when moving men etc.
    ///   - capturablePieces: The pieces that can be captured. Ie. all enemy pieces.
    ///   - direction: Tuple containing difference to capturable piece and then difference to square to go after capture
    /// - Returns: <#description#>
    func getCaptureMask(_ movablePieces: UInt64,
                        _ nonCapturablePieces: UInt64,
                        _ capturablePieces: UInt64,
                        _ direction: (Int, Int)
    ) -> UInt64 {
        // move direction is relative to the captured piece, not to the original position
        let (captureDiff, postCaptureDiff) = direction
        return movablePieces &
            ((capturablePieces & EightByEightBoard.notEdges)>>captureDiff) & ~((allPieces>>postCaptureDiff)>>captureDiff)
    }

    func capturePieces(
        _ pieceType: CheckersPiece,
        _ mask: UInt64,
        _ diff: (Int, Int),
        _ out: inout Set<GameState>
    ) {
        switch pieceType {
        case .BlackKing:
            for (blackKings, whiteMen, whiteKings) in Capture(
                piecesToMove: blackKings,
                pieceType: .BlackKing,
                capturableMen: whiteMen,
                capturableKings: whiteKings,
                nonCapturablePieces: blackMen,
                mask: mask,
                diff: diff
            ) {
                out.insert(GameState(
                            blackMen: blackMen,
                            blackKings: blackKings,
                            whiteMen: whiteMen,
                            whiteKings: whiteKings,
                            blackTurn: whiteTurn))
            }
        case .BlackMan:
            for (blackMen, whiteMen, whiteKings) in Capture(
                piecesToMove: blackMen,
                pieceType: .BlackMan,
                capturableMen: whiteMen,
                capturableKings: whiteKings,
                nonCapturablePieces: blackKings,
                mask: mask,
                diff: diff
            ) {
                let bk=blackKings|(blackMen&EightByEightBoard.whiteEnd) // new kings
                let bm=blackMen & ~bk
                out.insert(GameState(
                            blackMen: bm,
                            blackKings: bk,
                            whiteMen: whiteMen,
                            whiteKings: whiteKings,
                            blackTurn: whiteTurn))
            }
        case .WhiteKing:
            for (whiteKings, blackMen, blackKings) in Capture(
                piecesToMove: whiteKings,
                pieceType: .WhiteKing,
                capturableMen: blackMen,
                capturableKings: blackKings,
                nonCapturablePieces: whiteMen,
                mask: mask,
                diff: diff
            ) {
                out.insert(GameState(
                            blackMen: blackMen,
                            blackKings: blackKings,
                            whiteMen: whiteMen,
                            whiteKings: whiteKings,
                            blackTurn: whiteTurn))
            }

        case .WhiteMan:
            for (whiteMen, blackMen, blackKings) in Capture(
                piecesToMove: whiteMen,
                pieceType: .WhiteMan,
                capturableMen: blackMen,
                capturableKings: blackKings,
                nonCapturablePieces: whiteKings,
                mask: mask,
                diff: diff
            ) {
                let wk=whiteKings|(whiteMen&EightByEightBoard.blackEnd) // new kings
                let wm=whiteMen & ~wk
                out.insert(GameState(
                            blackMen: blackMen,
                            blackKings: blackKings,
                            whiteMen: wm,
                            whiteKings: wk,
                            blackTurn: whiteTurn))
            }
        }
    }

    func movePieces(
        _ pieceType: CheckersPiece,
        _ mask: UInt64,
        _ moveDiff: CheckersMoveDiff,
        _ out: inout Set<GameState>
    ) {
        switch pieceType {
        case .BlackKing:
            for bk in Move(blackKings, mask, moveDiff) {
                out.insert(GameState(
                            blackMen: blackMen,
                            blackKings: bk,
                            whiteMen: whiteMen,
                            whiteKings: whiteKings,
                            blackTurn: whiteTurn))
            }
        case .BlackMan:
            for bm in Move(blackMen, mask, moveDiff) {
                let bk=blackKings|(bm&EightByEightBoard.whiteEnd) // new kings
                let bm=bm & ~bk
                out.insert(GameState(
                            blackMen: bm,
                            blackKings: bk,
                            whiteMen: whiteMen,
                            whiteKings: whiteKings,
                            blackTurn: whiteTurn))
            }
        case .WhiteKing:
            for wk in Move(whiteKings, mask, moveDiff) {
                out.insert(GameState(
                            blackMen: blackMen,
                            blackKings: blackKings,
                            whiteMen: whiteMen,
                            whiteKings: wk,
                            blackTurn: whiteTurn))
            }

        case .WhiteMan:
            for wm in Move(whiteMen, mask, moveDiff) {
                let wk=whiteKings|(wm&EightByEightBoard.blackEnd) // new kings
                let wm=wm & ~wk
                out.insert(GameState(
                            blackMen: blackMen,
                            blackKings: blackKings,
                            whiteMen: wm,
                            whiteKings: wk,
                            blackTurn: whiteTurn))
            }
        }
    }
}
