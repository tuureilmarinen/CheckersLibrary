//
//  CheckersUtils.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.7.2021.
//

import Foundation

public enum CheckersUtils {

    public static func getMove(_ previousState: GameState, _ newState: GameState) -> (Int, Int, [Int]) {
        let (prev, curr, opp) = newState.blackTurn ?
            (previousState.whitePieces, newState.whitePieces, previousState.blackPieces^newState.blackPieces) :
            (previousState.blackPieces, newState.blackPieces, previousState.whitePieces^newState.whitePieces)
        let from = ((prev^curr)&prev).trailingZeroBitCount
        let to = ((prev^curr)&curr).trailingZeroBitCount
        return (from, to, getMaskIndexes(opp))
    }

    public static func getMoves(_ state: GameState) -> [Int: [(to: Int, captured: [Int], state: GameState)]] {
        var foundMoves: [Int: [(Int, [Int], GameState)]]=[:]
        for child in state.children {
            let (from, to, captured) = getMove(state, child)
            if foundMoves[from] != nil {
                var foundMovesForSinglePiece = foundMoves[from]!
                foundMovesForSinglePiece.append((to, captured, child))
                foundMoves[from]=foundMovesForSinglePiece
            } else {
                foundMoves[from]=[(to, captured, child)]
            }
        }
        return foundMoves
    }

    public static func getMaskIndexes(_ mask: UInt64) -> [Int] {
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
