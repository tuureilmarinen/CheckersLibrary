//
//  PortableDraughtsNotation.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 30.7.2021.
//

import Foundation

public enum PortableDraughtsNotation {
   
    /// Returns the square number of a dark square in the format used in the Portable Draughts Notation
    public static func IntToPDN(_ i:Int) -> Int{
        return (i/2)+1
    }

    public static func PDNToInt(_ p:Int) -> Int{
        return 2*p-(1+(p/4)%2)
    }

    public static func stateToFen(_ state: GameState) -> String {
        var w:[String]=[]
        var b:[String]=[]
        for x in 0...63 {
            if state.blackMen[x] {
                b.append(String(IntToPDN(x)))
            }
            if state.blackKings[x] {
                b.append("K"+String(IntToPDN(x)))
            }
            if state.whiteMen[x] {
                w.append(String(IntToPDN(x)))
            }
            if state.whiteKings[x] {
                w.append("K"+String(IntToPDN(x)))
            }
        }
        return (state.blackTurn ? "B" : "W")+":W"+(w.joined(separator:","))+":B"+(b.joined(separator:","))
        
        
    }
    public static func PDNfenToGameState(_ fen: String?) -> GameState? {
        guard fen != nil else { return nil }
        let fen = fen!
        func bitboards(_ s : String) -> (UInt64, UInt64) {
            var men: UInt64 = 0
            var kings: UInt64 = 0
            let pieces = s.split(separator: ",", omittingEmptySubsequences: true)
            for x in pieces {
                let (k, n) = parseNumberKing(String(x))
                if k {
                    kings[PDNToInt(n)]=true
                } else {
                    men[PDNToInt(n)]=true
                }
            }
            return (men,kings)
            
        }
        // wheter piece is king pdn number
        func parseNumberKing(_ x: String) -> (Bool, Int) {
            if x.prefix(1)=="K" || x.prefix(1)=="k" {
                return (Bool(true), Int(String(x[x.index(x.startIndex, offsetBy: 1)..<x.endIndex]))!)
            }
            return (Bool(false), Int(x)!)
            
        }
        
        
        let tmp = fen.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: true)
        let turn = tmp[0]
        let a=tmp[1]
        let b=tmp[2]
        let blackTurn = turn=="b"||turn=="B" ? true : false
        
        let ab = bitboards(String(a[a.index(a.startIndex, offsetBy: 1)..<a.endIndex]))
        let bb = bitboards(String(b[b.index(b.startIndex, offsetBy: 1)..<b.endIndex]))
        
        let ((bm,bk),(wm,wk)) = a.prefix(1)=="B" || a.prefix(1)=="b" ? (ab,bb) : (bb,ab)
        
        return GameState(blackMen: bm, blackKings: bk, whiteMen: wm, whiteKings: wk, blackTurn: blackTurn)
    }
    
}
