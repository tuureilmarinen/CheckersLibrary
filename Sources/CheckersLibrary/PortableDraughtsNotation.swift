//
//  PortableDraughtsNotation.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 30.7.2021.
//

import Foundation

public enum PortableDraughtsNotation {
    /// Returns the square number of a dark square in the format used in the Portable Draughts Notation
    public static func IntToPDN(_ index: Int) -> Int {
        return (index/2)+1
    }

    public static func PDNToInt(_ pdnSquareNumber: Int) -> Int {
        return 2*(pdnSquareNumber-1)+(((pdnSquareNumber-1)/4).isMultiple(of: 2) ? 1 : 0)
    }
    public static func encode(_ state: GameState) -> String {
        return state.encode(to: PortableDraughtsNotation.self)
    }
    public static func decode(_ fen: String?) -> GameState? {
        guard fen != nil else { return nil }
        return try? GameState.init(fen: fen!)
    }
}

extension GameState {
    enum GameStateDecodeArgumentError: Error {
        case invalidArgument
    }
    public func encode(to: PortableDraughtsNotation.Type) -> String {
        var whites: [String]=[]
        var blacks: [String]=[]
        for boardIndex in 0...63 {
            if self.board.blackMen[boardIndex] {
                blacks.append(String(PortableDraughtsNotation.IntToPDN(boardIndex)))
            }
            if self.board.blackKings[boardIndex] {
                blacks.append("K"+String(PortableDraughtsNotation.IntToPDN(boardIndex)))
            }
            if self.board.whiteMen[boardIndex] {
                whites.append(String(PortableDraughtsNotation.IntToPDN(boardIndex)))
            }
            if self.board.whiteKings[boardIndex] {
                whites.append("K"+String(PortableDraughtsNotation.IntToPDN(boardIndex)))
            }
        }
        return (self.blackTurn ? "B" : "W")+":W"+(whites.joined(separator: ","))+":B"+(blacks.joined(separator: ","))

    }
    public init(fen: String) throws {
        func bitboards(_ pdnString: String) -> (PieceSet, PieceSet) {
            var men = PieceSet(0)
            var kings = PieceSet(0)
            let pieces = pdnString.split(separator: ",", omittingEmptySubsequences: true)
            for piece in pieces {
                let (isKing, pdnSquareNumber) = parseNumberKing(String(piece))
                if isKing {
                    kings[PortableDraughtsNotation.PDNToInt(pdnSquareNumber)]=true
                } else {
                    men[PortableDraughtsNotation.PDNToInt(pdnSquareNumber)]=true
                }
            }
            return (men, kings)

        }
        // wheter piece is king pdn number
        func parseNumberKing(_ pieceString: String) -> (Bool, Int) {
            if pieceString.prefix(1)=="K" || pieceString.prefix(1)=="k" {
                return (Bool(true),
                        Int(String(
                                pieceString[pieceString.index(pieceString.startIndex,
                                                              offsetBy: 1)..<pieceString.endIndex])
                        )!)
            }
            return (Bool(false), Int(pieceString)!)

        }

        let fenArray = fen.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: true)
        guard fenArray.count==3 else { throw GameStateDecodeArgumentError.invalidArgument }
        let piecesA=fenArray[1]
        let piecesB=fenArray[2]
        let turn = fenArray[0]=="B" ? CheckersColor.Black : .White

        let bitboardsA = bitboards(String(piecesA[piecesA.index(piecesA.startIndex, offsetBy: 1)..<piecesA.endIndex]))
        let bitboardsB = bitboards(String(piecesB[piecesB.index(piecesB.startIndex, offsetBy: 1)..<piecesB.endIndex]))

        let ((blackMen, blackKings), (whiteMen, whiteKings)) = piecesA.prefix(1)=="B" || piecesA.prefix(1)=="b" ?
            (bitboardsA, bitboardsB) :
            (bitboardsB, bitboardsA)
        self.init(board: EightByEightBoard(
                    blackMen: blackMen,
                    blackKings: blackKings,
                    whiteMen: whiteMen,
                    whiteKings: whiteKings
        ), turn: turn)
    }
}
