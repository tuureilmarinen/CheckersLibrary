//
//  GameState.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 23.7.2021.
//

import Foundation

public enum CheckersPiece {
    case BlackMan, BlackKing, WhiteMan, WhiteKing, Empty
}

public enum CheckersColor{
    case Black
    case White
}

enum CheckersMoveDiff: Int {
    case DownLeft = 7
    case DownRight = 9
    case UpRight = -7
    case UpLeft = -9
    case Nothing = 0
}

struct CheckersCaptureDiff {
    static let DownLeft = (7,7)
    static let DownRight = (9,9)
    static let UpLeft = (-9,-9)
    static let UpRight = (-7,-7)
}

let legalJumpDirections : [CheckersPiece:[(Int,Int)]] = [
    .BlackMan: [CheckersCaptureDiff.DownLeft,CheckersCaptureDiff.DownRight],
    .WhiteMan: [CheckersCaptureDiff.UpLeft,CheckersCaptureDiff.UpRight],
    .BlackKing: [CheckersCaptureDiff.DownLeft,CheckersCaptureDiff.DownRight,CheckersCaptureDiff.UpLeft,CheckersCaptureDiff.UpRight],
    .WhiteKing: [CheckersCaptureDiff.DownLeft,CheckersCaptureDiff.DownRight,CheckersCaptureDiff.UpLeft,CheckersCaptureDiff.UpRight]
]

let CheckersDiff = (move: (down: (left: CheckersMoveDiff.DownLeft, right: CheckersMoveDiff.DownRight), up: (left: CheckersMoveDiff.UpLeft, right: CheckersMoveDiff.UpRight)), capture: (down: (left: CheckersCaptureDiff.DownLeft, right: CheckersCaptureDiff.DownRight), up: (left: CheckersCaptureDiff.UpLeft, right: CheckersCaptureDiff.UpRight)))

/// GameState contains state of the board.
/// It provides a way to get all legal moves from certain state.
public struct GameState: Hashable {
    /// The state of the board is represented by a bitboard. Bit at the least significant position represents square at the leftmost square on the topmost square.
    /// - Parameters:
    ///   - blackMen: Bitboard of the black men on the board.
    ///   - blackKings: Bitboard of the black men on the board.
    ///   - whiteMen: Bitboard of the black men on the board.
    ///   - whiteKings: Bitboard of the black men on the board.
    ///   - blackTurn: True, if the player with the black pieces should make the next move.
    init(blackMen: UInt64, blackKings: UInt64, whiteMen: UInt64, whiteKings: UInt64, blackTurn: Bool) {
        self.blackMen=blackMen
        self.blackKings=blackKings
        self.whiteMen=whiteMen
        self.whiteKings=whiteKings
        self.blackTurn=blackTurn
    }
    public var blackMen: UInt64
    public var blackKings: UInt64
    public var whiteMen: UInt64
    public var whiteKings: UInt64
    
    /* 0b1111_1111
        _1000_0001
        _1000_0001
        _1000_0001
        _1000_0001
        _1000_0001
        _1000_0001
        _1111_1111 */
    public static let edges:UInt64 = 18411139144890810879
    
    // ~edges
    public static let notEdges:UInt64 = 35604928818740736
    
    public static let rightEdge:UInt64 = 0b1000_0000_1000_0000_1000_0000_1000_0000_1000_0000_1000_0000_1000_0000_1000_0000
    
    public static let leftEdge:UInt64 = 0b0000_0001_0000_0001_0000_0001_0000_0001_0000_0001_0000_0001_0000_0001_0000_0001
    /*0b0000_0001
    _0000_0001
    _0000_0001
    _0000_0001
    _0000_0001
    _0000_0001
    _0000_0001
    _0000_0001*/
    
    // 0b1111_1111_0000...
    public static let whiteEndMask:UInt64 = 18374686479671623680
    
    /// 0b0000_0000_0000_.......1111_1111
    public static let blackEndMask:UInt64 = 255
    
    /// 0b0101_0101_1010_1010_0101_0101_1010_1010_0101_0101_1010_1010_0101_0101_1010_1010
    public static let darkSquares:UInt64 = 6172840429334713770
    /* 0b
        0101_0101_
        1010_1010_
        0101_0101_
        1010_1010_
        0101_0101_
        1010_1010_
        0101_0101_
        1010_1010 */
    
    /// ~darkSquares
    static let whiteSquares:UInt64 = 12273903644374837845
    
    
    /// ie. dark squares
    public static let playableSquares:UInt64 = 6172840429334713770
    
    // normal starting position
    // whiteMen = darkSquares & ~(UInt64.max>>16) = 6172746239264686080 = 0b101_0101_1010_1010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000
    // blackMen = darkSquares & ~(UInt64.max<<16) = 21930 = 0b0000_0000_..._0101_0101_1010_1010
    // blackKings=whiteKings=0
    public static let defaultStart = GameState(blackMen: 0b101_0101_1010_1010, blackKings: 0, whiteMen: 0b101_0101_1010_1010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000, whiteKings: 0, blackTurn: true)
    
    // A computed property of all black pieces on the board.
    public var blackPieces:UInt64 {
        return blackMen | blackKings
    }
    
    // A computed property of all black pieces on the board.
    public var whitePieces: UInt64 {
        return whiteMen | whiteKings
    }
    
    // A computed property of all pieces on the board.
    public var allPieces: UInt64 {
        return whiteMen | whiteKings | blackMen | blackKings
    }
    
    // Wheter the black should make the next turn.
    public var blackTurn: Bool
    
    // Wheter the white should make the next turn.
    public var whiteTurn: Bool {
        get {
            return !blackTurn
        }
        set(newWhiteTurnValue) {
            blackTurn = !newWhiteTurnValue
        }
    }
    
    /// The information about who should make the next turn.
    public var turn: CheckersColor {
        return self.blackTurn ? CheckersColor.Black : CheckersColor.White
    }
    
    /// Contains all legal states the current turn can lead to.
    public var children : Set<GameState> {
        var children: Set<GameState> = []
        var mask: UInt64
        if blackTurn {
            // Black Men Capture
            mask = getCaptureMask(blackMen, blackKings|whitePieces, whitePieces, CheckersDiff.capture.down.left)
            capturePieces(.BlackMan, mask, CheckersDiff.capture.down.left, &children)
            
            mask = getCaptureMask(blackMen, blackKings|whitePieces, whitePieces, CheckersDiff.capture.down.right)
            capturePieces(.BlackMan, mask, CheckersDiff.capture.down.right, &children)
            
            if blackKings>0 {
                // Black Kings Capture
                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.down.left)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.down.left, &children)
                
                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.down.right)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.down.right, &children)

                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.up.left)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.up.left, &children)
                
                mask = getCaptureMask(blackKings, blackMen|whitePieces, whitePieces, CheckersDiff.capture.up.right)
                capturePieces(.BlackKing, mask, CheckersDiff.capture.up.right, &children)
            }
            
            guard children.isEmpty else { return children }

            // Black Men Move
            mask = getMoveMask(blackMen & ~GameState.leftEdge, allPieces, CheckersDiff.move.down.left)
            movePieces(.BlackMan, mask, CheckersDiff.move.down.left, &children)
            
            mask = getMoveMask(blackMen & ~GameState.rightEdge, allPieces, CheckersDiff.move.down.right)
            movePieces(.BlackMan, mask, CheckersDiff.move.down.right, &children)
            
            if blackKings>0 {
                // Black Kings Move
                mask=getMoveMask(blackKings & ~GameState.leftEdge, allPieces, CheckersDiff.move.down.left)
                movePieces(.BlackKing, mask, CheckersDiff.move.down.left, &children)
                
                mask=getMoveMask(blackKings & ~GameState.rightEdge, allPieces, CheckersDiff.move.down.right)
                movePieces(.BlackKing, mask, CheckersDiff.move.down.right, &children)
                
                mask=getMoveMask(blackKings & ~GameState.leftEdge, allPieces, CheckersDiff.move.up.left)
                movePieces(.BlackKing, mask, CheckersDiff.move.up.left, &children)
                
                mask=getMoveMask(blackKings & ~GameState.rightEdge, allPieces, CheckersDiff.move.up.right)
                movePieces(.BlackKing, mask, CheckersDiff.move.up.right, &children)
            }
        } else { // white Turn
            // White Men Capture
            mask = getCaptureMask(whiteMen, whiteKings|blackPieces, blackPieces, CheckersDiff.capture.up.left)
            capturePieces(.WhiteMan, mask, CheckersDiff.capture.up.left, &children)
            
            mask = getCaptureMask(whiteMen, whiteKings|blackPieces, blackPieces, CheckersDiff.capture.up.right)
            capturePieces(.WhiteMan, mask, CheckersDiff.capture.up.right, &children)
            
            if whiteKings>0 {
                // White Kings Capture
                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.down.left)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.down.left, &children)
                
                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.down.right)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.down.right, &children)

                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.up.left)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.up.left, &children)
                
                mask = getCaptureMask(whiteKings, whiteMen|blackPieces, blackPieces, CheckersDiff.capture.up.right)
                capturePieces(.WhiteKing, mask, CheckersDiff.capture.up.right, &children)
            }
            
            guard children.isEmpty else { return children }

            // White Men Move
            mask = getMoveMask(whiteMen & ~GameState.leftEdge , allPieces, CheckersDiff.move.up.left)
            movePieces(.WhiteMan, mask, CheckersDiff.move.up.left, &children)
            mask = getMoveMask(whiteMen & ~GameState.rightEdge, allPieces, CheckersDiff.move.up.right)
            movePieces(.WhiteMan, mask, CheckersDiff.move.up.right, &children)
                    
            if whiteKings>0 {
                // White Kings Move
                mask = getMoveMask(whiteKings & ~GameState.leftEdge, allPieces, CheckersDiff.move.down.left)
                movePieces(.WhiteKing, mask, CheckersDiff.move.down.left, &children)
                
                mask = getMoveMask(whiteKings & ~GameState.rightEdge, allPieces, CheckersDiff.move.down.right)
                movePieces(.WhiteKing, mask, CheckersDiff.move.down.right, &children)
                
                mask = getMoveMask(whiteKings & ~GameState.leftEdge, allPieces, CheckersDiff.move.up.left)
                movePieces(.WhiteKing, mask, CheckersDiff.move.up.left, &children)
                
                mask = getMoveMask(whiteKings & ~GameState.rightEdge, allPieces, CheckersDiff.move.up.right)
                movePieces(.WhiteKing, mask, CheckersDiff.move.up.right, &children)
            }
        }
        return children
    }
    
    
    /// Provides mask of pieces of certain type that can move to certain direction.
    /// - Parameters:
    ///   - movablePieces: the pieces that are moved. Only one type of pieces can be provided.
    ///   - nonMovablePieces: all other pieces. Eg. if movablePieces is blackMen, nonMovablePieces is blackKings|whitePieces
    ///   - direction: the direction in which move is made.
    /// - Returns: Mask of pieces that can be moved to specified direction.
    func getMoveMask(_ movablePieces: UInt64, _ nonMovablePieces: UInt64, _ direction: CheckersMoveDiff) -> UInt64{
        let diff=direction.rawValue
        return (movablePieces<<diff & (~(((movablePieces|nonMovablePieces)))))>>diff
    }
    
    /// Provides mask of the movable pieces that can capture one of the capturable pieces and then land to a unoccupied square.
    /// - Parameters:
    ///   - movablePieces: bitboard of movable pieces
    ///   - nonCapturablePieces: the pieces that cannot be captured. Usually the kings of same color when moving men etc.
    ///   - capturablePieces: The pieces that can be captured. Ie. all enemy pieces.
    ///   - direction: Tuple containing difference to capturable piece and then difference to square to go after capture
    /// - Returns: <#description#>
    func getCaptureMask(_ movablePieces: UInt64,
                        _ nonCapturablePieces: UInt64,
                        _ capturablePieces : UInt64,
                        _ direction: (Int, Int)
    ) -> UInt64{
        // move direction is relative to the captured piece, not to the original position
        let (captureDiff, postCaptureDiff) = direction
        return movablePieces & ((capturablePieces & GameState.notEdges)>>captureDiff) & ~((allPieces>>postCaptureDiff)>>captureDiff)
    }
    
    func capturePieces(_ pieceType: CheckersPiece,_ mask: UInt64, _ diff: (Int,Int), _ out: inout Set<GameState>) {
        
        switch pieceType {
        case .BlackKing:
            for (blackKings, whiteMen, whiteKings) in Capture(piecesToMove: blackKings, pieceType: .BlackKing, capturableMen: whiteMen, capturableKings: whiteKings, nonCapturablePieces:blackMen, mask: mask, diff: diff) {
                out.insert(GameState(blackMen: blackMen, blackKings: blackKings, whiteMen: whiteMen, whiteKings: whiteKings, blackTurn: whiteTurn))
            }
        case .BlackMan:
            for (blackMen, whiteMen, whiteKings) in Capture(piecesToMove: blackMen, pieceType: .BlackMan, capturableMen: whiteMen, capturableKings: whiteKings, nonCapturablePieces:blackKings, mask: mask, diff: diff) {
                let bk=blackKings|(blackMen&GameState.whiteEndMask) // new kings
                let bm=blackMen & ~bk
                out.insert(GameState(blackMen: bm, blackKings: bk, whiteMen: whiteMen, whiteKings: whiteKings, blackTurn: whiteTurn))
            }
        case .WhiteKing:
            for (whiteKings, blackMen, blackKings) in Capture(piecesToMove: whiteKings, pieceType: .WhiteKing, capturableMen: blackMen, capturableKings: blackKings, nonCapturablePieces:whiteMen, mask: mask, diff: diff) {
                out.insert(GameState(blackMen: blackMen, blackKings: blackKings, whiteMen: whiteMen, whiteKings: whiteKings, blackTurn: whiteTurn))
            }

        case .WhiteMan:
            for (whiteMen, blackMen, blackKings) in Capture(piecesToMove: whiteMen, pieceType: .WhiteMan, capturableMen: blackMen, capturableKings: blackKings, nonCapturablePieces:whiteKings, mask: mask, diff: diff) {
                let wk=whiteKings|(whiteMen&GameState.blackEndMask) // new kings
                let wm=whiteMen & ~wk
                out.insert(GameState(blackMen: blackMen, blackKings: blackKings, whiteMen: wm, whiteKings: wk, blackTurn: whiteTurn))
            }

        default:
            _=1^1
            //throw RuntimeError("Empty piece passed as piece to move.")
        }
    }
    
    func movePieces(_ pieceType: CheckersPiece,_ mask: UInt64, _ moveDiff: CheckersMoveDiff, _ out: inout Set<GameState>) -> Void {
        //var out:Set<GameState>=[]
        switch pieceType {
        case .BlackKing:
            for bk in Move(blackKings, mask, moveDiff) {
                out.insert(GameState(blackMen: blackMen, blackKings: bk, whiteMen: whiteMen, whiteKings: whiteKings, blackTurn: whiteTurn))
            }
        case .BlackMan:
            for bm in Move(blackMen, mask, moveDiff) {
                let bk=blackKings|(bm&GameState.whiteEndMask) // new kings
                let bm=bm & ~bk
                out.insert(GameState(blackMen: bm, blackKings: bk, whiteMen: whiteMen, whiteKings: whiteKings, blackTurn: whiteTurn))
            }
        case .WhiteKing:
            for wk in Move(whiteKings, mask, moveDiff) {
                out.insert(GameState(blackMen: blackMen, blackKings: blackKings, whiteMen: whiteMen, whiteKings: wk, blackTurn: whiteTurn))
            }

        case .WhiteMan:
            for wm in Move(whiteMen, mask, moveDiff) {
                let wk=whiteKings|(wm&GameState.blackEndMask) // new kings
                let wm=wm & ~wk
                out.insert(GameState(blackMen: blackMen, blackKings: blackKings, whiteMen: wm, whiteKings: wk, blackTurn: whiteTurn))
            }

        default:
            _=1^1//throw RuntimeError("Empty piece passed as piece to move.")
        }
    }
    
    
    public func pieceAt(_ pos: Int) -> CheckersPiece {
        if (blackMen>>pos & 1) == 1 { return CheckersPiece.BlackMan }
        else if (blackKings>>pos & 1) == 1 { return CheckersPiece.BlackKing }
        else if (whiteKings>>pos & 1) == 1 { return CheckersPiece.WhiteKing }
        else if (whiteMen>>pos & 1) == 1 { return CheckersPiece.WhiteMan }
        else { return CheckersPiece.Empty }
    }
    
    public func piece(at: Int) -> CheckersPiece {
        return pieceAt(at)
    }
    
    
    private static func bitAt(a: Int, pos: Int) -> Bool {
        return (a>>pos & 1) == 1
    }
    
    struct Capture: Sequence {
        let piecesToMove:UInt64
        let pieceType:CheckersPiece
        let capturableMen:UInt64
        let capturableKings:UInt64
        let nonCapturablePieces:UInt64
        let mask:UInt64
        let diff:(Int,Int)
        func makeIterator() -> CaptureIterator {
            return CaptureIterator(self)
        }
    }

    struct CaptureIterator: IteratorProtocol {
        private var captureMask: UInt64
        private var moveMask:UInt64
        private var from:UInt64
        private var to:UInt64
        private var iteratorMask: UInt64
        private let piecesToMove:UInt64
        private let capturableMen:UInt64
        private let capturableKings:UInt64
        private let nonCapturablePieces:UInt64
        private var chainedCaptures:[(UInt64,UInt64,UInt64)]=[]
        private var legalCaptureDiffs:[(Int,Int)]
        private var pos:Int=0
        private var moveDiff:Int
        
        init(_ capture: Capture) {
            self.moveMask=(1<<(capture.diff.0+capture.diff.1)) | 1
            
            self.moveDiff=capture.diff.1+capture.diff.0
            if moveDiff>0 {
                //print("d>0")
                from=1
                to=1<<moveDiff
                self.iteratorMask = capture.mask // move.mask>>move.diff.rawValue
                self.captureMask=1<<capture.diff.0
            } else { //white
                //print("d<0")
                from = (1<<abs(moveDiff))
                to = 1
                self.iteratorMask = capture.mask>>abs(moveDiff) // move.mask>>move.diff.rawValue
                self.captureMask=1<<abs(capture.diff.0)
            }
            //self.pos=self.iteratorMask.trailingZeroBitCount
            
            //self.iteratorMask=capture.mask
            self.piecesToMove=capture.piecesToMove
            self.capturableMen=capture.capturableMen
            self.capturableKings=capture.capturableKings
            self.nonCapturablePieces=capture.nonCapturablePieces
            self.legalCaptureDiffs=legalJumpDirections[capture.pieceType]!
        }
        
        mutating func next() -> (UInt64,UInt64,UInt64)? {
            guard chainedCaptures.isEmpty else {
                return chainedCaptures.removeFirst()
            }
            guard iteratorMask > 0
                else { return nil }

            pos+=iteratorMask.trailingZeroBitCount
            //moveMask<<=iteratorMask.trailingZeroBitCount
            from<<=iteratorMask.trailingZeroBitCount
            to<<=iteratorMask.trailingZeroBitCount
            captureMask<<=iteratorMask.trailingZeroBitCount
            iteratorMask>>=iteratorMask.trailingZeroBitCount
            iteratorMask^=1

            let x=((piecesToMove & (~from)) | to , capturableMen & ~captureMask, capturableKings & ~captureMask)
            let foundChainedCaptures = checkForChainedCaptures(pos+moveDiff, x.0, x.1, x.2)
            //print("found chained \(foundChainedCaptures)")
            return foundChainedCaptures ? chainedCaptures.removeFirst() : x
        }
        
        private mutating func checkForChainedCaptures(_ pos:Int, _ mp:UInt64, _ om:UInt64, _ ok: UInt64) -> Bool {
            var foundChainedCaptures:Bool=false
            //print("looking chained from \(TerminalUI.IntToPDN(pos)) as int:\(pos)")
            for (c,m) in legalCaptureDiffs {
                //print("pos+m+c \(TerminalUI.IntToPDN(pos+m+c)) as int:\(pos+m+c) pos:\(pos) m:\(m) c:\(c) notedge:\(GameState.notEdges[pos+c]) pos+c has om:\(om[pos+c]) pos+c has ok:\(ok[pos+c])")
                let freeSquares = ~(mp|nonCapturablePieces|om|ok)
                if freeSquares[pos+c+m] && GameState.notEdges[pos+c] {
                    if om[pos+c] {
                        foundChainedCaptures=true
                        //print("Square \(TerminalUI.IntToPDN(pos+m+c)) has opp. man")
                        var nom=om
                        nom[pos+c]=false
                        var nmp=mp
                        nmp[pos+m+c]=true
                        nmp[pos]=false
                        let foundMoreChainedCaptures = checkForChainedCaptures(pos+m+c,nmp,nom,ok)
                        if !foundMoreChainedCaptures {
                            self.chainedCaptures.append((nmp,nom,ok))
                            foundChainedCaptures=true
                        }
                        foundChainedCaptures=foundChainedCaptures||foundMoreChainedCaptures
                    } else if ok[pos+c] {
                        foundChainedCaptures=true
                        //print("Square \(TerminalUI.IntToPDN(pos+m+c)) has opp. king")
                        var nok=ok
                        nok[pos+c]=false
                        var nmp=mp
                        nmp[pos+m+c]=true
                        nmp[pos]=false
                        foundChainedCaptures=foundChainedCaptures||checkForChainedCaptures(pos+m+c,nmp,om,nok)
                        let foundMoreChainedCaptures = checkForChainedCaptures(pos+m+c,nmp,om,nok)
                        if !foundMoreChainedCaptures {
                            self.chainedCaptures.append((nmp,om,nok))
                            foundChainedCaptures=true
                        }
                        foundChainedCaptures=foundChainedCaptures||foundMoreChainedCaptures
                    } else {
                        _=1^1//print("Square \(TerminalUI.IntToPDN(pos+c)) has no opponent.")
                    }
                } else { _=1^1 }//print("Square \(TerminalUI.IntToPDN(pos+m+c)) is occupied")}
            }
            //print("found chained \(foundChainedCaptures) from \(TerminalUI.IntToPDN(pos))")
            return foundChainedCaptures
        }
        
        
    }

    struct Move: Sequence {
        let piecesToMove:UInt64
        let mask:UInt64
        let diff:CheckersMoveDiff
        init(_ piecesToMove: UInt64, _ mask: UInt64, _ diff: CheckersMoveDiff){
            self.piecesToMove=piecesToMove
            self.mask=mask
            self.diff=diff
        }
        func makeIterator() -> MoveIterator {
            return MoveIterator(self)
        }
    }

    struct MoveIterator: IteratorProtocol {
        //private var moveMask: UInt64
        private var from:UInt64
        private var to:UInt64
        private var iteratorMask: UInt64
        private let piecesToMove:UInt64
        
        init(_ move: Move) {
            // mask has the pieces in original places
            //self.moveMask = (1 << move.diff.rawValue.magnitude | 1) >> move.diff.rawValue
            if move.diff.rawValue>0 {
                from=1
                to=1<<move.diff.rawValue
                self.iteratorMask = move.mask // move.mask>>move.diff.rawValue
            } else {
                from = (1<<abs(move.diff.rawValue))
                to = 1
                self.iteratorMask = move.mask>>abs(move.diff.rawValue) // move.mask>>move.diff.rawValue
            }
            //self.iteratorMask = move.mask // move.mask>>move.diff.rawValue
            self.piecesToMove = move.piecesToMove
            
             
        }
        mutating func next() -> UInt64? {
            guard iteratorMask > 0
                else { return nil }
            from<<=iteratorMask.trailingZeroBitCount
            to<<=iteratorMask.trailingZeroBitCount
            iteratorMask>>=iteratorMask.trailingZeroBitCount
            iteratorMask^=1

            return (piecesToMove|to)&(~from)
            //return piecesToMove^moveMask
        }
    }


}

