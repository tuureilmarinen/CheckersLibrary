//
//  CheckersColor.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.8.2021.
//

import Foundation

public enum CheckersColor {
    case Black
    case White
    func flip() -> CheckersColor {
        return self == .Black ? .White : .Black
    }
    func man() -> CheckersPiece {
        return self == .Black ? .BlackMan : .WhiteMan
    }
    func king() -> CheckersPiece {
        return self == .Black ? .BlackKing : .WhiteKing
    }
    func selector() -> CheckersPieceSelector {
        return self == .Black ? .Black : .White
    }
}
