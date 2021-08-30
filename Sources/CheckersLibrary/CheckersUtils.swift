//
//  CheckersUtils.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.7.2021.
//

import Foundation

public struct CheckersMove {
    public let from: Int
    public let to: Int
    public let captured: [Int]
    public let previous: GameState
    public let next: GameState?
}

public enum CheckersUtils {

    public static func encode(dump state: GameState) -> String {
        return state.encode(to: String.self)
    }
    public static func decode(dump: String) -> GameState? {
        return try? GameState.init(dump: dump)
    }

    public static func getMove(_ previousState: GameState, _ newState: GameState) -> CheckersMove {
        let (prev, curr, opp) = newState.blackTurn ?
            (previousState.board.whitePieces,
             newState.board.whitePieces,
             previousState.board.blackPieces^newState.board.blackPieces) :
            (previousState.board.blackPieces,
             newState.board.blackPieces,
             previousState.board.whitePieces^newState.board.whitePieces)
        let from = ((prev^curr)&prev).pieces.trailingZeroBitCount
        let to = ((prev^curr)&curr).pieces.trailingZeroBitCount
        return CheckersMove(
            from: from,
            to: to,
            captured: opp.indexes,
            previous: previousState,
            next: newState)
    }

    public static func getMoves(_ state: GameState) -> [Int: [CheckersMove]] {
        var foundMoves: [Int: [CheckersMove]] = [:]
        for child in state.children {
            let move = getMove(state, child)
            if foundMoves[move.from] != nil {
                var foundMovesForSinglePiece = foundMoves[move.from]!
                foundMovesForSinglePiece.append(move)
                foundMoves[move.from]=foundMovesForSinglePiece
            } else {
                foundMoves[move.from]=[move]
            }
        }
        return foundMoves
    }

    public static func getSetBitIndexes<T: FixedWidthInteger&BinaryInteger>(_ mask: T) -> [Int] {
        var setBitIndexes: [Int] = []
        var mask = mask
        while mask>0 {
            setBitIndexes.append(mask.trailingZeroBitCount)
            mask>>=mask.trailingZeroBitCount
            mask^=1
        }
        return setBitIndexes
    }
}

extension EightByEightBoard {
    enum DecodeArgumentError: Error {
        case invalidLength(dumpLength: Int)
        case invalidCharacter
        case invalidArgument
    }
    public func encode(to: String.Type) -> String {
        var tmp = Array(repeating: 0, count: 64)
        for at in 0...63 {
            if (self.blackMen.pieces>>at) & UInt64(1) == 1 {
                tmp[at]+=1
            }
            if (self.blackKings.pieces>>at) & UInt64(1) == 1 {
                tmp[at]+=2            }
            if (self.whiteMen.pieces>>at) & UInt64(1) == 1 {
                tmp[at]+=4            }
            if (self.whiteKings.pieces>>at) & UInt64(1) == 1 {
                tmp[at]+=8            }
        }
        return tmp.map { String(format: "%X", $0) } .joined()
    }
    public init(dump: String) throws {
        let a=Array(dump)
        guard a.count==64 else { throw DecodeArgumentError.invalidLength(dumpLength: a.count) }
        /*guard a.allSatisfy({
            ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"].contains($0)
        }) else { throw DecodeArgumentError.invalidCharacter }*/
        var bm: UInt64=0
        var bk: UInt64=0
        var wm: UInt64=0
        var wk: UInt64=0
        for at in (0...63).reversed() {
            wk<<=1
            wm<<=1
            bk<<=1
            bm<<=1
            var x = UInt8(strtoul(String(a[at]), nil, 16))
            if x>=8 {
                x-=8
                wk|=1
            }
            if x>=4 {
                x-=4
                wm|=1
            }
            if x>=2 {
                x-=2
                bk|=1
            }
            if x>=1 {
                bm|=1
            }

        }
        self.init(blackMen: bm, blackKings: bk, whiteMen: wm, whiteKings: wk)
    }
}

extension GameState {
    public func encode(to: String.Type) -> String {
        return self.board.encode(to: String.self) + (self.blackTurn ? "B":"W")
    }

    public init(dump: String) throws {
        guard dump.count == 65 else { throw GameStateDecodeArgumentError.invalidArgument }
        let board = try? EightByEightBoard(dump: String(dump.dropLast(1)))
        guard board != nil else { throw GameStateDecodeArgumentError.invalidArgument }

        self.init(
            board: board!,
            turn: dump.dropFirst(64)=="B" ? .Black : .White
        )
    }
}
