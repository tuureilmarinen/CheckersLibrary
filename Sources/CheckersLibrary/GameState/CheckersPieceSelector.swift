//
//  CheckersPieceSelector.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.8.2021.
//

import Foundation

public enum CheckersPieceSelector: Equatable {
    case Black
    case White
    case WhiteMen
    case WhiteKings
    case BlackMen
    case BlackKings
    case All
    case Empty
    case At([Int])
    public func suit() -> CheckersPieceSelector? {
        if [CheckersPieceSelector.White, .WhiteMen, .WhiteKings].contains(self) {
            return .White
        } else if [CheckersPieceSelector.Black, .BlackMen, .BlackKings].contains(self) {
            return .Black
        }
        return nil
    }

    public func enemySuit() -> CheckersPieceSelector? {
        if [CheckersPieceSelector.White, .WhiteMen, .WhiteKings].contains(self) {
            return .Black
        } else if [CheckersPieceSelector.Black, .BlackMen, .BlackKings].contains(self) {
            return .Black
        }
        return nil
    }
}
