//
//  CheckersUtils.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.7.2021.
//

import Foundation

public enum CheckersUtils {

    public static func getMove(_ previousState: GameState, _ newState: GameState) -> (Int,Int,[Int]) {
        let (prev,curr,opp) = newState.blackTurn ? (previousState.whitePieces, newState.whitePieces, previousState.blackPieces^newState.blackPieces) : (previousState.blackPieces, newState.blackPieces, previousState.whitePieces^newState.whitePieces)
        let from = ((prev^curr)&prev).trailingZeroBitCount
        let to = ((prev^curr)&curr).trailingZeroBitCount
        return (from,to,getMaskIndexes(opp))
    }
    
    public static func getMoves(_ state: GameState) -> [Int:[(Int,[Int],GameState)]] {
        var ret:[Int:[(Int,[Int],GameState)]]=[:]
        for c in state.children {
            let (from, to, captured) = getMove(state,c)
            if ret[from] != nil {
                var p = ret[from]!
                p.append((to,captured,c))
                ret[from]=p
            } else {
                ret[from]=[(to,captured,c)]
            }
        }
        return ret
    }

    public static func getMaskIndexes(_ mask:UInt64) -> [Int]{
        var r:[Int] = []
        var m = mask
        repeat {
            r.append(m.trailingZeroBitCount)
            m>>=m.trailingZeroBitCount
            m^=1

        } while m>0
        return r
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
    
    public static func getRandomGameState(turn:CheckersColor?=nil, blackMen:Int=0, whiteMen:Int=0, blackKings:Int=0, whiteKings:Int=0)->GameState{
        var unoccupied:UInt64=GameState.playableSquares
        let bm=getRandomBitsSet(unoccupied, blackMen)
        unoccupied &= ~bm
        let bk=getRandomBitsSet(unoccupied, blackKings)
        unoccupied &= ~bk
        let wk=getRandomBitsSet(unoccupied, whiteKings)
        unoccupied &= ~wk
        let wm=getRandomBitsSet(unoccupied, whiteMen)
        let bt = (turn == nil ? Bool.random() : turn! == .Black)
        return GameState(blackMen: bm, blackKings: bk, whiteMen: wm, whiteKings: wk, blackTurn: bt)
    }
}
