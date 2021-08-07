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

    public static func getSetBitIndexes(_ mask: UInt64) -> [Int] {
        var setBitIndexes: [Int] = []
        var mask = mask
        repeat {
            setBitIndexes.append(mask.trailingZeroBitCount)
            mask>>=mask.trailingZeroBitCount
            mask^=1

        } while mask>0
        return setBitIndexes
    }

    public static func getRandomBitsSet<T: FixedWidthInteger>(_ choices: T, _ count: Int) -> T {
        guard count>0 && choices != 0 else {
            return 0
        }
        var tmp=choices
        for _ in 0..<T.random(in: 0..<T(choices.nonzeroBitCount)) {
            tmp^=T(1)<<tmp.trailingZeroBitCount

        }
        let selection = T(1)<<tmp.trailingZeroBitCount

        return selection | getRandomBitsSet(choices^selection, count-1)
    }

    public static func getRandomGameState(
        turn: CheckersColor?=nil,
        blackMen: Int=0,
        whiteMen: Int=0,
        blackKings: Int=0,
        whiteKings: Int=0
    ) -> GameState {
        var unoccupied: UInt64=GameState.playableSquares
        let blackMen=getRandomBitsSet(unoccupied, blackMen)
        unoccupied &= ~blackMen
        let blackKings=getRandomBitsSet(unoccupied, blackKings)
        unoccupied &= ~blackKings
        let whiteKings=getRandomBitsSet(unoccupied, whiteKings)
        unoccupied &= ~whiteKings
        let whiteMen=getRandomBitsSet(unoccupied, whiteMen)
        let isBlackTurn = (turn == nil ? Bool.random() : turn! == .Black)
        return GameState(
            blackMen: blackMen,
            blackKings: blackKings,
            whiteMen: whiteMen,
            whiteKings: whiteKings,
            blackTurn: isBlackTurn)
    }
}
