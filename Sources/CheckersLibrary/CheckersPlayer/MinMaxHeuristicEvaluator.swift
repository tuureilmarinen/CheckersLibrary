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

public struct PieceCountRatioEvaluator: MinMaxHeuristicEvaluator {
    public static func evaluate(_ state: GameState) -> Double {
        let returnValue = Double(state.whitePieces.nonzeroBitCount)/Double(state.blackPieces.nonzeroBitCount)
        return returnValue > 1 ? returnValue : (1.0/returnValue) * -1
    }
}
