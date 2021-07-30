//
//  File.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.7.2021.
//

import Foundation

public protocol CheckersPlayer {
    func provideMove(_ state: GameState) -> GameState?
    var name:String {get}
    init()
}
