//
//  CheckersMinMax.swift
//  CheckersMinMax
//
//  Created by Tuure Ilmarinen on 23.7.2021.
//

import Foundation

public class CheckersMinMax: CheckersPlayer {

    private var currentState: GameState!

    /// When key state has black turn, value state has smallest possible value
    /// if key state has white turn, value state has maximum possible value
    public var optimalKnownMove: [GameState: GameState] = [:]
    // positive or negative infinity means that win can be forced
    public var knownValues: [GameState: Double] = [:]

    /// How many turns had been evaluated when determining the best move without finding a way to sure win.
    public var guessDepth: [GameState: Int] = [:]

    /// initial search depth
    public var searchDepth = 8

    /// how many moves deep must evaluation have taken place, in order to accept result from cache, Int.max disables.
    public var cacheDepth = 5

    public var evaluator: MinMaxHeuristicEvaluator

    public var name: String {
        return "Min-Max with alpha-beta pruning. " +
            "Search dept: \(searchDepth), cache depth: \(cacheDepth)"
    }

    required public init() {
        evaluator = WeightedPieceCountRatioEvaluator()
    }

    /// Provides method to provide move from certain state.
    /// Implements CheckersPlayer protocol
    /// - Parameter state: The current state of the game.
    /// - Returns: The best found move found by the algorithm.
    public func provideMove(_ state: GameState) -> GameState? {
        currentState=state
        return provideMoveWithMinMaxAlphaBeta(state)
    }

    /// Initializes the minimax algorithm and calls it.
    /// - Parameter state: the current state of the game.
    /// - Returns: The best found move.
    private func provideMoveWithMinMaxAlphaBeta(_ state: GameState) -> GameState? {
        _ = minMaxWithAlphaBeta(
            state: state,
            depth: self.searchDepth,
            alpha: -Double.infinity,
            beta: Double.infinity,
            evaluator: evaluator)
        return optimalKnownMove[state]
    }

    // swiftlint:disable cyclomatic_complexity function_body_length

    /// Minimax algorithm with alpha-beta-pruning.
    ///  Search depth is limited by depth parameter.
    ///  Fail-soft.
    /// - Parameters:
    ///   - state: Starting state
    ///   - depth: Maximum search depth.
    ///   - alpha: alpha is the minimum value that is guaranteed to the maximizing player, white.
    ///   - beta: beta is the maximum value that is guaranteed to the minimizing player, black.
    /// - Returns: If value is positive infinity, white can force win, if negative infinity, black can force win.
    /// Values that are not infinite, are approximations.
    private func minMaxWithAlphaBeta (
        state: GameState,
        depth: Int,
        alpha: Double,
        beta: Double,
        evaluator: MinMaxHeuristicEvaluator,
        currentDepth: Int=0
    ) -> Double {
        var alpha=alpha
        var beta=beta
        let children = state.children

        if knownValues[state] != nil {
            let (value, overflow) = (guessDepth[state]!).addingReportingOverflow(currentDepth)
            if overflow || value>cacheDepth {
                return knownValues[state]!
            }
        }
        // White win = max, black win =min
        else if children.isEmpty {
            return state.blackTurn ? Double.infinity : -Double.infinity
        } else if currentDepth==depth {
            return evaluator.evaluate(state)
        }

        if state.whiteTurn { // white turn -> maximizing
            var highestFoundValue = -Double.infinity
            var highestChild: GameState = children.first!
            for child in children {
                let childValue = minMaxWithAlphaBeta(
                    state: child,
                    depth: depth,
                    alpha: alpha,
                    beta: beta,
                    evaluator: evaluator,
                    currentDepth: currentDepth+1)
                if childValue>=highestFoundValue {
                    highestFoundValue = childValue
                    highestChild = child
                }
                guard highestFoundValue < beta else { break } // beta cutoff
                alpha=max(alpha, highestFoundValue)

            }
            optimalKnownMove[state] = highestChild
            guessDepth[state] = highestFoundValue.magnitude ==  .infinity ? Int.max : (depth-currentDepth)
            knownValues[state]=highestFoundValue
            return highestFoundValue
        } else { // black turn -> minimizing
            var smallestFoundValue = Double.infinity
            var smallestChild: GameState=children.first!
            for child in children {
                let childValue = minMaxWithAlphaBeta(
                    state: child,
                    depth: depth,
                    alpha: alpha,
                    beta: beta,
                    evaluator: evaluator,
                    currentDepth: currentDepth+1)
                if childValue<=smallestFoundValue {
                    smallestFoundValue = childValue
                    smallestChild=child
                }
                guard smallestFoundValue>alpha else { break } // alpha cutoff
                beta=min(beta, smallestFoundValue)

            }
            guessDepth[state] = smallestFoundValue.magnitude ==  .infinity ? Int.max : (depth-currentDepth)
            optimalKnownMove[state] = smallestChild
            knownValues[state]=smallestFoundValue
            return smallestFoundValue
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
