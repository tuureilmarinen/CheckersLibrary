//
//  CheckersDeterministicRandomPlayer.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 30.7.2021.
//

import Foundation

public struct CheckersDeterministicRandomPlayer: CheckersPlayer {
    public var name: String {
        return "DeterministicRandom (seed:\(seed))"
    }
    public var seed: UInt64 = 1
    public init() {}

    private func arbitarySorter(_ rhs: GameState, _ lhs: GameState) -> Bool {
        var rHasher = Hasher()
        rHasher.combine(rhs)
        let rHash = rHasher.finalize()
        var lHasher = Hasher()
        lHasher.combine(lhs)
        let lHash = lHasher.finalize()
        return rHash<lHash
    }
    public func provideMove(_ state: GameState) -> GameState? {
        let options=state.children
        if options.isEmpty {
            return nil
        }
        let sorted=Array(options).sorted(by: arbitarySorter)
        let distance=UInt64(sorted.distance(from: sorted.startIndex, to: sorted.endIndex))
        let bitsJustCrammedTogether=state.blackMen ^ state.blackMen.byteSwapped ^ state.blackKings.byteSwapped ^ state.whiteMen.byteSwapped ^ state.whiteKings.byteSwapped / seed
        let selectedIndex = Int((state.blackTurn ? bitsJustCrammedTogether : ~bitsJustCrammedTogether)%distance)
        print("dist: \(distance) sel:\(selectedIndex) \(bitsJustCrammedTogether)")
        return sorted[selectedIndex]
    }
}
