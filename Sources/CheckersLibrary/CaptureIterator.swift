//
//  CaptureIterator.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 21.8.2021.
//

import Foundation
struct Capture: Sequence {
    let piecesToMove: UInt64
    let pieceType: CheckersPiece
    let capturableMen: UInt64
    let capturableKings: UInt64
    let nonCapturablePieces: UInt64
    let mask: UInt64
    let diff: (Int, Int)
    func makeIterator() -> CaptureIterator {
        return CaptureIterator(self)
    }
}

struct CaptureIterator: IteratorProtocol {
    private var captureMask: UInt64
    private var moveMask: UInt64
    private var from: UInt64
    private var to: UInt64
    private var iteratorMask: UInt64
    private let piecesToMove: UInt64
    private let capturableMen: UInt64
    private let capturableKings: UInt64
    private let nonCapturablePieces: UInt64
    private var chainedCaptures: [(UInt64, UInt64, UInt64)]=[]
    private var legalCaptureDiffs: [(Int, Int)]
    private var pos: Int=0
    private var moveDiff: Int

    init(_ capture: Capture) {
        self.moveMask=(1<<(capture.diff.0+capture.diff.1)) | 1
        self.moveDiff=capture.diff.1+capture.diff.0
        if moveDiff>0 {
            from=1
            to=1<<moveDiff
            self.iteratorMask = capture.mask
            self.captureMask=1<<capture.diff.0
        } else {
            from = (1<<abs(moveDiff))
            to = 1
            self.iteratorMask = capture.mask>>abs(moveDiff)
            self.captureMask=1<<abs(capture.diff.0)
        }
        self.piecesToMove=capture.piecesToMove
        self.capturableMen=capture.capturableMen
        self.capturableKings=capture.capturableKings
        self.nonCapturablePieces=capture.nonCapturablePieces
        self.legalCaptureDiffs=legalJumpDirections[capture.pieceType]!
    }

    mutating func next() -> (UInt64, UInt64, UInt64)? {
        guard chainedCaptures.isEmpty else {
            return chainedCaptures.removeFirst()
        }
        guard iteratorMask > 0
            else { return nil }

        pos+=iteratorMask.trailingZeroBitCount
        from<<=iteratorMask.trailingZeroBitCount
        to<<=iteratorMask.trailingZeroBitCount
        captureMask<<=iteratorMask.trailingZeroBitCount
        iteratorMask>>=iteratorMask.trailingZeroBitCount
        iteratorMask^=1

        let foundChainedCaptureStep=((piecesToMove & (~from)) | to,
               capturableMen & ~captureMask,
               capturableKings & ~captureMask)
        let foundChainedCaptures = checkForChainedCaptures(
            pos+moveDiff,
            foundChainedCaptureStep.0,
            foundChainedCaptureStep.1,
            foundChainedCaptureStep.2)
        return foundChainedCaptures ? chainedCaptures.removeFirst() : foundChainedCaptureStep
    }

    private mutating func checkForChainedCaptures(
        _ pos: Int,
        _ movablePieces: UInt64,
        _ opponentMen: UInt64,
        _ opponentKings: UInt64
    ) -> Bool {
        var foundChainedCaptures: Bool=false
        for (captureDiff, moveDiff) in legalCaptureDiffs {
            let freeSquares = ~(movablePieces|nonCapturablePieces|opponentMen|opponentKings)
            if freeSquares[pos+captureDiff+moveDiff] && EightByEightBoard.notEdges[pos+captureDiff] {
                if opponentMen[pos+captureDiff] {
                    foundChainedCaptures=true
                    var newOpponentMen=opponentMen
                    newOpponentMen[pos+captureDiff]=false
                    var newMovablePieces=movablePieces
                    newMovablePieces[pos+moveDiff+captureDiff]=true
                    newMovablePieces[pos]=false
                    let foundMoreChainedCaptures = checkForChainedCaptures(
                        pos+moveDiff+captureDiff,
                        newMovablePieces,
                        newOpponentMen,
                        opponentKings)
                    if !foundMoreChainedCaptures {
                        self.chainedCaptures.append((newMovablePieces, newOpponentMen, opponentKings))
                        foundChainedCaptures=true
                    }
                    foundChainedCaptures=foundChainedCaptures||foundMoreChainedCaptures
                } else if opponentKings[pos+captureDiff] {
                    foundChainedCaptures=true
                    var newOpponentKings=opponentKings
                    newOpponentKings[pos+captureDiff]=false
                    var newMovalbePieces=movablePieces
                    newMovalbePieces[pos+moveDiff+captureDiff]=true
                    newMovalbePieces[pos]=false
                    foundChainedCaptures=foundChainedCaptures||checkForChainedCaptures(
                        pos+moveDiff+captureDiff,
                        newMovalbePieces,
                        opponentMen,
                        newOpponentKings)
                    let foundMoreChainedCaptures = checkForChainedCaptures(
                        pos+moveDiff+captureDiff,
                        newMovalbePieces,
                        opponentMen,
                        newOpponentKings)
                    if !foundMoreChainedCaptures {
                        self.chainedCaptures.append((newMovalbePieces, opponentMen, newOpponentKings))
                        foundChainedCaptures=true
                    }
                    foundChainedCaptures=foundChainedCaptures||foundMoreChainedCaptures
                }
            }
        }
        return foundChainedCaptures
    }

}
