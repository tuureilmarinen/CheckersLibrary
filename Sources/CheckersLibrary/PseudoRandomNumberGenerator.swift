//
//  PseudoRandomNumberGenerator.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 25.8.2021.
//

import Foundation

struct PseudoRandomNumberGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
        }
    func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}

struct RandomUtils {
    public static func getRandomBitsSet<T: FixedWidthInteger>(_ choices: T, _ count: Int) -> T {
        var generator = SystemRandomNumberGenerator()
        return getRandomBitsSet(choices, count, using: &generator)
    }
    public static func getRandomBitsSet<E, T: FixedWidthInteger>(
        _ choices: T,
        _ count: Int,
        using: inout E
    ) -> T where E: RandomNumberGenerator {
        guard count>0 && choices != 0 else {
            return 0
        }
        var generator = using
        var tmp=choices
        for _ in 0..<T.random(in: 0..<T(choices.nonzeroBitCount), using: &generator) {
            tmp^=T(1)<<tmp.trailingZeroBitCount

        }
        let selection = T(1)<<tmp.trailingZeroBitCount

        return selection | getRandomBitsSet(choices^selection, count-1, using: &generator)
    }
}
extension GameState {
    public static func random(
        turn: CheckersColor?=nil,
        blackMen: Int=0,
        whiteMen: Int=0,
        blackKings: Int=0,
        whiteKings: Int=0
    ) -> GameState {
        var generator = SystemRandomNumberGenerator()
        return random(
            turn: turn,
            blackMen: blackMen,
            whiteMen: whiteMen,
            blackKings: blackKings,
            whiteKings: whiteKings,
            using: &generator)
    }
    public static func random<T>(
        turn: CheckersColor?=nil,
        blackMen: Int=0,
        whiteMen: Int=0,
        blackKings: Int=0,
        whiteKings: Int=0,
        using: inout T
    ) -> GameState where T: RandomNumberGenerator {
        var state: GameState
        var generator = using
        repeat {
            var unoccupied: UInt64=GameState.playableSquares
            let blackMen=RandomUtils.getRandomBitsSet(unoccupied, blackMen)
            unoccupied &= ~blackMen
            let blackKings=RandomUtils.getRandomBitsSet(unoccupied, blackKings)
            unoccupied &= ~blackKings
            let whiteKings=RandomUtils.getRandomBitsSet(unoccupied, whiteKings)
            unoccupied &= ~whiteKings
            let whiteMen=RandomUtils.getRandomBitsSet(unoccupied, whiteMen)
            let isBlackTurn = (turn == nil ? Bool.random(using: &generator) : turn! == .Black)
            state = GameState(
                blackMen: blackMen,
                blackKings: blackKings,
                whiteMen: whiteMen,
                whiteKings: whiteKings,
                blackTurn: isBlackTurn)
        } while !state.valid
        return state
    }
}
