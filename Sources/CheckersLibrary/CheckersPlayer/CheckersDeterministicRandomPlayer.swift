//
//  CheckersDeterministicRandomPlayer.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 30.7.2021.
//

import Foundation

/// CheckersDeterministicRandomPlayer makes always a same move from same state of the game if the seed is same.
public struct CheckersDeterministicRandomPlayer: CheckersPlayer {
    public init() {
        self.init(seed: 1)
    }

    public var name: String {
        return "DeterministicRandom (seed:\(seed))"
    }
    public var seed: Int
    private var generator: PseudoRandomNumberGenerator
    public init(seed: Int = 1) {
        self.seed=seed
        generator=PseudoRandomNumberGenerator(seed: seed)
    }

    private func arbitarySorter(_ rhs: GameState, _ lhs: GameState) -> Bool {
        var rHasher = Hasher()
        rHasher.combine(rhs)
        let rHash = rHasher.finalize()
        var lHasher = Hasher()
        lHasher.combine(lhs)
        let lHash = lHasher.finalize()
        return rHash<lHash
    }
    public mutating func provideMove(_ state: GameState) -> GameState? {
        let options=state.children
        if options.isEmpty {
            return nil
        }
        let sorted=Array(options).sorted(by: arbitarySorter)
        return sorted.randomElement(using: &generator)
    }
}
