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

    public static func getMove(_ previousState: GameState, _ newState: GameState) -> CheckersMove {
        let (prev, curr, opp) = newState.blackTurn ?
            (previousState.whitePieces, newState.whitePieces, previousState.blackPieces^newState.blackPieces) :
            (previousState.blackPieces, newState.blackPieces, previousState.whitePieces^newState.whitePieces)
        let from = ((prev^curr)&prev).trailingZeroBitCount
        let to = ((prev^curr)&curr).trailingZeroBitCount
        return CheckersMove(
            from: from,
            to: to,
            captured: getSetBitIndexes(opp),
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

    public static func encode(dump: GameState) -> String {
        var tmp = Array(repeating: 0, count: 64)
        for at in 0...63 {
            if (dump.blackMen>>at & 1) == 1 {
                tmp[at]+=1
            }
            if (dump.blackKings>>at & 1) == 1 {
                tmp[at]+=2            }
            if (dump.whiteMen>>at & 1) == 1 {
                tmp[at]+=4            }
            if (dump.whiteKings>>at & 1) == 1 {
                tmp[at]+=8            }
        }
        return tmp.map { String(format: "%X", $0) } .joined() + (dump.blackTurn ? "B":"W")
    }
    public static func decode(dump: String?) -> GameState? {
        guard dump != nil else { return nil }
        let a=Array(dump!)
        guard a.count==65 else { return nil }
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
        let bt = a[64]=="B" ? true : false
        return GameState(blackMen: bm, blackKings: bk, whiteMen: wm, whiteKings: wk, blackTurn: bt)
    }
}
