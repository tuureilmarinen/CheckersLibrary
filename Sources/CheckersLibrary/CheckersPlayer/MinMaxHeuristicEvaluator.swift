//
//  MinMaxHeuristicEvaluator.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 13.8.2021.
//

import Foundation

public protocol MinMaxHeuristicEvaluator {
    static func evaluate(_: GameState) -> Double
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
    public static func evaluate(_ state: GameState) -> Double {
        let returnValue = Double(state.whitePieces.nonzeroBitCount)/Double(state.blackPieces.nonzeroBitCount)
        return returnValue > 1 ? returnValue : (1.0/returnValue) * -1
    }
}
