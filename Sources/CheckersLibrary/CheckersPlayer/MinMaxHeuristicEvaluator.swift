//
//  MinMaxHeuristicEvaluator.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 13.8.2021.
//

import Foundation

public protocol MinMaxHeuristicEvaluator {
    func evaluate(_: GameState) -> Double
}

/// Provides heuristic function for the CheckersMinMax by comparing ratios of pieces on the board.
public struct PieceCountRatioEvaluator: MinMaxHeuristicEvaluator {
    /// It compares ratio of pieces on the board.
    /// Number of white pieces is divided by number of black pieces,
    /// or number of black pieces divided by white pieces multiplied by -1
    /// if number of black pieces on the board is greater.
    /// Complexity is O(1).
    /// - Parameter state: GameState to be evaluated.
    /// - Returns: Positive value if situation if favorable for the white player, negative if it is not.
    public func evaluate(_ state: GameState) -> Double {
        let returnValue = Double(state.whitePieces.nonzeroBitCount)/Double(state.blackPieces.nonzeroBitCount)
        return returnValue > 1 ? returnValue : (1.0/returnValue) * -1
    }
}


/// Provides heuristic function for the CheckersMinMax by comparing ratios of pieces on the board but weighting the count of kings.
public struct WeightedPieceCountRatioEvaluator: MinMaxHeuristicEvaluator {
    var pieceWeight:Double
    var kingWeight:Double
    var turnWeight:Double
    var remainingMenWeight:Double
    var remainingKingsWeight:Double

    public init(piece:Double=24, king:Double=2, turn:Double=1, men:Double = .infinity, kings:Double = .infinity) {
        kingWeight=king
        pieceWeight=piece
        turnWeight=turn
        remainingMenWeight=men
        remainingKingsWeight=kings
    }

    public func evaluate(_ state: GameState) -> Double {
        if state.number(of: .Black)==0 {
            return Double(state.number(of: .WhiteKings))*remainingKingsWeight+Double(state.number(of: .WhiteMen))*remainingMenWeight
        } else if state.number(of: .White)==0 {
            return Double(state.number(of: .WhiteKings))*remainingKingsWeight+Double(state.number(of: .WhiteMen))*remainingMenWeight
        } else if state.number(of: .Black)>state.number(of: .White) {
            let pieceRatio = Double(state.number(of: .White))/Double(state.number(of: .Black))
            let kingRatio = Double(state.number(of: .WhiteKings))/Double(max(state.number(of: .WhiteMen),1))
            let turnRatio:Double = state.turn == .White ? 1 : 0
            return pieceRatio*pieceWeight+kingRatio*kingWeight+turnRatio*turnWeight-1
        } else {
            let pieceRatio = Double(state.number(of: .Black))/Double(state.number(of: .White))
            let kingRatio = Double(state.number(of: .BlackKings))/Double(max(state.number(of: .BlackMen),1))
            let turnRatio:Double = state.turn == .White ? 1 : 0
            return -1*(pieceRatio*pieceWeight+kingRatio*kingWeight+turnRatio*turnWeight-1)

        }
    }
}

