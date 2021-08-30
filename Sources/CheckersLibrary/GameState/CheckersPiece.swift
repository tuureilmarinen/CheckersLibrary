//
//  CheckersPiece.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 28.8.2021.
//

import Foundation

public enum CheckersPiece: Int {
    case BlackMan = 1
    case BlackKing = 2
    case WhiteMan = 3
    case WhiteKing = 4

    func color (_ color: CheckersColor) -> Bool {
        return (self.rawValue<3 && color == .Black) || (self.rawValue>2 && color == .White)
    }

    func selector() -> CheckersPieceSelector {
        switch self {
        case .BlackMan:
            return .BlackMen
        case .BlackKing:
            return .BlackKings
        case .WhiteMan:
            return .WhiteMen
        case .WhiteKing:
            return .WhiteKings
        }
    }
}
