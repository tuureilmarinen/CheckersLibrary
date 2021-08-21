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
        return 2*pdnSquareNumber-(1+(pdnSquareNumber/4)%2)
    }

    public static func stateToFen(_ state: GameState) -> String {
        var whites: [String]=[]
        var blacks: [String]=[]
        for boardIndex in 0...63 {
            if state.blackMen[boardIndex] {
                blacks.append(String(IntToPDN(boardIndex)))
            }
            if state.blackKings[boardIndex] {
                blacks.append("K"+String(IntToPDN(boardIndex)))
            }
            if state.whiteMen[boardIndex] {
                whites.append(String(IntToPDN(boardIndex)))
            }
            if state.whiteKings[boardIndex] {
                whites.append("K"+String(IntToPDN(boardIndex)))
            }
        }
        return (state.blackTurn ? "B" : "W")+":W"+(whites.joined(separator: ","))+":B"+(blacks.joined(separator: ","))

    }
    public static func PDNfenToGameState(_ fen: String?) -> GameState? {
        guard fen != nil else { return nil }
        let fen = fen!
        func bitboards(_ pdnString: String) -> (UInt64, UInt64) {
            var men: UInt64 = 0
            var kings: UInt64 = 0
            let pieces = pdnString.split(separator: ",", omittingEmptySubsequences: true)
            for piece in pieces {
                let (isKing, pdnSquareNumber) = parseNumberKing(String(piece))
                if isKing {
                    kings[PDNToInt(pdnSquareNumber)]=true
                } else {
                    men[PDNToInt(pdnSquareNumber)]=true
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
        guard fenArray.count==3 else { return nil }
        let turn = fenArray[0]
        let piecesA=fenArray[1]
        let piecesB=fenArray[2]
        let blackTurn = turn=="b"||turn=="B" ? true : false

        let bitboardsA = bitboards(String(piecesA[piecesA.index(piecesA.startIndex, offsetBy: 1)..<piecesA.endIndex]))
        let bitboardsB = bitboards(String(piecesB[piecesB.index(piecesB.startIndex, offsetBy: 1)..<piecesB.endIndex]))

        let ((blackMen, blackKings), (whiteMen, whiteKings)) = piecesA.prefix(1)=="B" || piecesA.prefix(1)=="b" ?
            (bitboardsA, bitboardsB) :
            (bitboardsB, bitboardsA)

        return GameState(
            blackMen: blackMen,
            blackKings: blackKings,
            whiteMen: whiteMen,
            whiteKings: whiteKings,
            blackTurn: blackTurn)
    }

}
