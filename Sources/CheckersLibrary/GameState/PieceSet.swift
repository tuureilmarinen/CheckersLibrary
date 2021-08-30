//
//  PieceSet.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 27.8.2021.
//

import Foundation

public struct PieceSet: Equatable, Hashable, Codable, Identifiable {
    public var id: UInt64 {
        return self.pieces
    }

    public var pieces: UInt64
    public var count: Int {
        return pieces.nonzeroBitCount
    }
    public init(_ pieces: UInt64) {
        self.pieces = pieces
    }
    public init(_ indexes: [Int]) {
        pieces=0
        for i in indexes {
            pieces|=UInt64(1)<<i
        }
    }

    public func and(not: PieceSet) -> PieceSet {
        return PieceSet(pieces & ~not.pieces)
    }

    public func and(_ and: PieceSet) -> PieceSet {
        return PieceSet(pieces & and.pieces)
    }

    public func or(_ other: PieceSet) -> PieceSet {
        return PieceSet(pieces | other.pieces)
    }

    public var isEmpty: Bool {
        return pieces==0
    }

    public var isNotEmpty: Bool {
        return pieces>0
    }

    static prefix func ~ (set: PieceSet) -> PieceSet {
        return PieceSet(~set.pieces)
    }

    static func & (left: PieceSet, right: PieceSet) -> PieceSet {
        return PieceSet(left.pieces & right.pieces)
    }
    static func | (left: PieceSet, right: PieceSet) -> PieceSet {
        return PieceSet(left.pieces | right.pieces)
    }

    static func << (left: PieceSet, right: Int) -> PieceSet {
        return PieceSet(left.pieces<<right)
    }
    static func >> (left: PieceSet, right: Int) -> PieceSet {
        return PieceSet(left.pieces>>right)
    }

    static func ^ (left: PieceSet, right: PieceSet) -> PieceSet {
        return PieceSet(left.pieces<<right.pieces)
    }

    public var indexes: [Int] {
        var setBitIndexes: [Int] = []
        var mask = self.pieces
        var acc = 0
        while mask>0 {
            setBitIndexes.append(mask.trailingZeroBitCount+acc)
            acc += mask.trailingZeroBitCount
            mask>>=mask.trailingZeroBitCount
            mask^=1
        }
        return setBitIndexes
    }
    subscript(index: Int) -> Bool {
        get {
            return self.pieces&(1<<index) > 0
        }
        set(newValue) {
            if newValue {
                self.pieces = self.pieces | (1<<index)
            } else {
                self.pieces = self.pieces & (~(1<<index))
            }
        }
    }
}

extension UInt64 {
    public init(_ pieceSet: PieceSet) {
        self=pieceSet.pieces
    }
}
