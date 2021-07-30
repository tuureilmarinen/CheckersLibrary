//
//  CheckersRandomPlayer.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 26.7.2021.
//

import Foundation

public struct CheckersRandomPlayer: CheckersPlayer {
    public var name: String = "Random"
    public init() {}
    public func provideMove(_ state: GameState) -> GameState? {
        return state.children.randomElement()
    }
}
