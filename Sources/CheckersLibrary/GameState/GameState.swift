//
//  GameState.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 23.7.2021.
//

import Foundation

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
        board=EightByEightBoard(blackMen: blackMen, blackKings: blackKings, whiteMen: whiteMen, whiteKings: whiteKings)
        self.blackTurn=blackTurn
    }

    public init(board: EightByEightBoard, turn: CheckersColor) {
        self.board = board
        self.blackTurn = turn == .Black
    }

    public init(board: EightByEightBoard, blackTurn: Bool) {
        self.board = board
        self.blackTurn = blackTurn
    }

    public var board: EightByEightBoard

    public var id: String {
        return encode(to: String.self)
    }

    public var description: String { return "GameState: \(encode(to: String.self))" }

    public var valid: Bool {
        return (board.whiteMen & board.whiteKings).isEmpty &&
            (board.whiteMen & board.blackMen).isEmpty &&
            (board.whiteMen & board.blackKings).isEmpty &&
            (board.blackMen & board.blackKings).isEmpty &&
            (board.blackMen & board.whiteKings).isEmpty &&
            (board.blackKings & board.whiteKings).isEmpty &&
            ((board.whiteMen | board.whiteKings | board.blackMen | board.blackKings) &
                (~GameState.playableSquares)).isEmpty &&
            (board.blackMen & EightByEightBoard.whiteEnd).isEmpty &&
            (board.whiteMen & EightByEightBoard.blackEnd).isEmpty
    }

    /// ie. dark squares
    public static var playableSquares: PieceSet {
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

    public func pieces(_ selection: CheckersPieceSelector, except: CheckersPieceSelector? = nil) -> PieceSet {
        return board.pieces(selection, except: except)
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

    private static func boardsToGameStates(
        boards: Set<EightByEightBoard>,
        turn: CheckersColor
    ) -> Set<GameState> {
        return Set<GameState>(boards.map {
            GameState(
                board: $0
                    .turn(.BlackMan, into: .BlackKing, at: EightByEightBoard.whiteEnd)
                    .turn(.WhiteMan, into: .WhiteKing, at: EightByEightBoard.blackEnd),
                turn: turn
            )
        })
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
        let opponentSelector = turn.flip().selector()
        let menCaptures = GameState.capture(
            opponentSelector,
            using: turn.man().selector(),
            on: board,
            in: GameState.captureDirections(of: turn.man()))
        let kingsCaptures = GameState.capture(
            opponentSelector,
            using: turn.king().selector(),
            on: board,
            in: GameState.captureDirections(of: turn.king())
        )
        let captureBoards=menCaptures.union(kingsCaptures)
        if captureBoards.isEmpty {
            let menMoves=GameState.move(
                using: turn.man().selector(),
                on: board,
                to: GameState.moveDirections(of: turn.man()))
            let kingMoves=GameState.move(
                using: turn.king().selector(),
                on: board,
                to: GameState.moveDirections(of: turn.king()))
            return GameState.boardsToGameStates(boards: menMoves.union(kingMoves), turn: turn.flip())
        }
        return GameState.boardsToGameStates(boards: captureBoards, turn: turn.flip())

    }

    public func number(of pieces: CheckersPieceSelector) -> Int {
        return valid ? (board.pieces(pieces) & GameState.playableSquares).count : board.pieces(pieces).count
    }

    static func moveDirections(of: CheckersPiece) -> [Direction] {
        switch of {
        case .BlackMan:
            return [
                Direction(.Down(1), .Left(1)),
                Direction(.Down(1), .Right(1))
            ]
        case .WhiteMan:
            return [
                Direction(.Up(1), .Left(1)),
                Direction(.Up(1), .Right(1))
            ]
        case .WhiteKing, .BlackKing:
            return [
                Direction(.Down(1), .Left(1)),
                Direction(.Down(1), .Right(1)),
                Direction(.Up(1), .Left(1)),
                Direction(.Up(1), .Right(1))
            ]
        }
    }
    static func captureDirections(of: CheckersPiece) -> [CaptureDirection] {
        switch of {
        case .BlackMan:
            return [
                CaptureDirection(
                    capture: Direction(.Down(1), .Left(1)),
                    land: Direction(.Down(1), .Left(1))
                ),
                CaptureDirection(
                    capture: Direction(.Down(1), .Right(1)),
                    land: Direction(.Down(1), .Right(1))
                )
            ]
        case .WhiteMan:
            return [
                CaptureDirection(
                    capture: Direction(.Up(1), .Left(1)),
                    land: Direction(.Up(1), .Left(1))
                ),
                CaptureDirection(
                    capture: Direction(.Up(1), .Right(1)),
                    land: Direction(.Up(1), .Right(1))
                )
            ]
        case .BlackKing, .WhiteKing:
            return [
                CaptureDirection(
                    capture: Direction(.Down(1), .Left(1)),
                    land: Direction(.Down(1), .Left(1))
                ),
                CaptureDirection(
                    capture: Direction(.Down(1), .Right(1)),
                    land: Direction(.Down(1), .Right(1))
                ),
                CaptureDirection(
                    capture: Direction(.Up(1), .Left(1)),
                    land: Direction(.Up(1), .Left(1))
                ),
                CaptureDirection(
                    capture: Direction(.Up(1), .Right(1)),
                    land: Direction(.Up(1), .Right(1))
                )
            ]
        }
    }

    static func move(
        using pieces: CheckersPieceSelector,
        on board: EightByEightBoard,
        to directions: [Direction]
    ) -> Set<EightByEightBoard> {
        return GameState.move(
            using: pieces,
            at: GameState.playableSquares,
            on: board,
            to: directions
        )
    }
    static func move(
        using pieces: CheckersPieceSelector,
        at squares: PieceSet=GameState.playableSquares,
        on board: EightByEightBoard,
        to directions: [Direction]
    ) -> Set<EightByEightBoard> {
        var ret: Set<EightByEightBoard> = []
        let board = board & squares
        let empty=board.pieces(.Empty)
        for land in directions {
            let landedBoard = board.move(pieces, land)
            let landedBoardOnEmpty = landedBoard & empty
            let movingPieces = landedBoardOnEmpty.move(back: pieces, land)
            let movingPiecesFiltered=movingPieces.pieces(pieces)
            for i in movingPiecesFiltered.indexes {
                let foundMove = board.move(.At([i]), land)
                ret.insert(foundMove)
            }
        }
        return ret
    }
    static func capture(
        _ enemySelector: CheckersPieceSelector,
        using pieces: CheckersPieceSelector,
        on board: EightByEightBoard,
        in directions: [CaptureDirection]
    ) -> Set<EightByEightBoard> {
        return GameState.capture(enemySelector, using: pieces, at: GameState.playableSquares, on: board, in: directions)
    }

    static func capture(
        _ enemySelector: CheckersPieceSelector,
        using pieces: CheckersPieceSelector,
        at squares: PieceSet=GameState.playableSquares,
        on board: EightByEightBoard,
        in directions: [CaptureDirection]
    ) -> Set<EightByEightBoard> {
        var ret: Set<EightByEightBoard> = []
        let enemies=board.pieces(enemySelector) & EightByEightBoard.notEdges
        let empty=board.pieces(.Empty)

        for direction in directions {
            let capturingBoard = board.move(pieces, direction.capture) & enemies // board.pieces(pieces.enemySuit()!))
            let landedBoard = capturingBoard.move(pieces, direction.land) & empty
            let movingPieces = landedBoard.move(back: pieces, direction.capture+direction.land).pieces(pieces)

            for i in movingPieces.indexes {
                let newBoard = board.move(.At([i]), direction.capture+direction.land)
                    .remove(at: direction.capture, from: PieceSet([i]))

                let chained = GameState.capture(
                    enemySelector,
                    using: .At(
                        [i+EightByEightBoard.shift(direction.capture+direction.land)]
                    ),
                    on: newBoard,
                    in: directions
                )
                if chained.isEmpty {
                    ret.insert(newBoard)
                } else {
                    ret.formUnion(chained)
                }

            }
        }
        return ret
    }
}
