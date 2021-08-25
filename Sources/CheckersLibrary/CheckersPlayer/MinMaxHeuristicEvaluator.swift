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
    public init() {}
    /// It compares ratio of pieces on the board.
    /// Number of white pieces is divided by number of black pieces,
    /// or number of black pieces divided by white pieces multiplied by -1
    /// if number of black pieces on the board is greater.
    /// Complexity is O(1).
    /// - Parameter state: GameState to be evaluated.
    /// - Returns: Positive value if situation if favorable for the white player, negative if it is not.
    public func evaluate(_ state: GameState) -> Double {
        let returnValue = Double(state.whitePieces.nonzeroBitCount)/Double(state.blackPieces.nonzeroBitCount)-1
        return returnValue > 1 ? returnValue : (1.0/returnValue) * -1
    }
}

/// Provides heuristic function for the CheckersMinMax
/// by comparing ratios of pieces on the board but weighting the count of kings.
public struct WeightedPieceCountRatioEvaluator: MinMaxHeuristicEvaluator {
    public var piece: Double
    public var king: Double
    public var turn: Double
    public var remainingMen: Double
    public var remainingKings: Double

    public init(piece: Double=24, king: Double=2, turn: Double=1, remainingMen: Double = .infinity, remainingKings: Double = .infinity) {
        self.king=king
        self.piece=piece
        self.turn=turn
        self.remainingMen=remainingMen
        self.remainingKings=remainingKings
    }

    public func evaluate(_ state: GameState) -> Double {
        if state.number(of: .Black)==0 {
            return Double(state.number(of: .WhiteKings)) * remainingKings +
                Double(state.number(of: .WhiteMen))*remainingMen
        } else if state.number(of: .White)==0 {
            return -1 * (Double(state.number(of: .BlackKings)) * remainingKings +
                Double(state.number(of: .BlackMen))*remainingMen)
        } else if state.number(of: .Black)>state.number(of: .White) {
            let pieceRatio = Double(state.number(of: .Black))/Double(state.number(of: .White))
            let kingRatio = Double(state.number(of: .BlackKings))/Double(max(state.number(of: .BlackMen), 1))
            let turnRatio: Double = state.turn == .Black ? 1 : 0
            return -1*(pieceRatio*piece+kingRatio*king+turnRatio*turn-1)
        } else {
            let pieceRatio = Double(state.number(of: .White))/Double(state.number(of: .Black))
            let kingRatio = Double(state.number(of: .WhiteKings)) /
                Double(max(state.number(of: .WhiteMen), 1))
            let turnRatio: Double = state.turn == .White ? 1 : 0
            return (pieceRatio*piece)+(kingRatio*king)+(turnRatio*turn)-1
        }
    }
}
