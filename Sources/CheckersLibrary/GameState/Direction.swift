//
//  Direction.swift
//  CheckersLibrary
//
//  Created by Tuure Ilmarinen on 30.8.2021.
//

import Foundation

public struct CaptureDirection: Equatable {
    public init(capture: Direction, land: Direction) {
        self.capture = capture
        self.land = land
    }

    public var capture: Direction
    public var land: Direction
}

public struct Direction: Equatable {
    public init(_ vertical: UpDown, _ horizontal: LeftRight) {
        self.vertical = vertical
        self.horizontal = horizontal
    }

    public var vertical: UpDown
    public var horizontal: LeftRight

    public func flip() -> Direction {
        return Direction(vertical.flip(), horizontal.flip())
    }
    static func + (left: Direction, right: Direction) -> Direction {
        return Direction(left.vertical+right.vertical, left.horizontal+right.horizontal)
    }
}

public enum UpDown: Equatable {
    case Up(Int)
    case Down(Int)
    case None

    public func flip() -> UpDown {
        switch self {
        case .Up(let u):
            return .Down(u)
        case .Down(let d):
            return .Up(d)
        default:
            return .None
        }
    }

    private static func create(up: Int, down: Int) -> UpDown {
        if up==down {
            return .None
        } else if up<down {
            return .Down(down-up)
        }
        return .Up(up-down)
    }
    static func + (left: UpDown, right: UpDown) -> UpDown {
        switch (left, right) {
        case (.Up(let up), .Down(let down)):
            return create(up: up, down: down)
        case (.Down(let down), .Up(let up)):
            return create(up: up, down: down)
        case (.Down(let down1), .Down(let down2)):
            return .Down(down1+down2)
        case (.Up(let up1), .Up(let up2)):
            return .Up(up1+up2)
        default:
            return left == .None ? right : left
        }
    }
}

public enum LeftRight: Equatable {
    case Left(Int)
    case Right(Int)
    case None
    public func flip() -> LeftRight {
        switch self {
        case .Left(let l):
            return .Right(l)
        case .Right(let r):
            return .Left(r)
        default:
            return .None
        }
    }
    static func + (left: LeftRight, right: LeftRight) -> LeftRight {
        switch (left, right) {
        case (.Left(let left), .Right(let right)):
            return create(left: left, right: right)
        case (.Right(let right), .Left(let left)):
            return create(left: left, right: right)
        case (.Right(let right1), .Right(let right2)):
            return .Right(right1+right2)
        case (.Left(let left1), .Left(let left2)):
            return .Left(left1+left2)
        default:
            return left == .None ? right : left
        }
    }
    private static func create(left: Int, right: Int) -> LeftRight {
        if left==right {
            return .None
        } else if left<right {
            return .Right(right-left)
        }
        return .Left(left-right)
    }
}
