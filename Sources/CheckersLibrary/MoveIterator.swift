//
//  MoveIterator.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 21.8.2021.
//

import Foundation

struct Move: Sequence {
    let piecesToMove: UInt64
    let mask: UInt64
    let diff: CheckersMoveDiff
    init(_ piecesToMove: UInt64, _ mask: UInt64, _ diff: CheckersMoveDiff) {
        self.piecesToMove=piecesToMove
        self.mask=mask
        self.diff=diff
    }
    func makeIterator() -> MoveIterator {
        return MoveIterator(self)
    }
}

struct MoveIterator: IteratorProtocol {
    private var from: UInt64
    private var to: UInt64
    private var iteratorMask: UInt64
    private let piecesToMove: UInt64

    init(_ move: Move) {
        // mask has the pieces in original places
        if move.diff.rawValue>0 {
            from=1
            to=1<<move.diff.rawValue
            self.iteratorMask = move.mask
        } else {
            from = (1<<abs(move.diff.rawValue))
            to = 1
            self.iteratorMask = move.mask>>abs(move.diff.rawValue)
        }
        self.piecesToMove = move.piecesToMove

    }
    mutating func next() -> UInt64? {
        guard iteratorMask > 0
            else { return nil }
        from<<=iteratorMask.trailingZeroBitCount
        to<<=iteratorMask.trailingZeroBitCount
        iteratorMask>>=iteratorMask.trailingZeroBitCount
        iteratorMask^=1

        return (piecesToMove|to)&(~from)
    }
}
