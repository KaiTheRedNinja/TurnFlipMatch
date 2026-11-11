//
//  Hold.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 9/11/26.
//

import SwiftUI

struct Hold: Identifiable, Equatable {
    var id: HoldID

    var side1Colors: HoldSideColors
    var side2Colors: HoldSideColors

    var position: HoldPosition
    var angle: Angle

    init(id: HoldID, side1Colors: HoldSideColors, side2Colors: HoldSideColors, position: HoldPosition, angle: Angle? = nil) {
        self.id = id
        self.side1Colors = side1Colors
        self.side2Colors = side2Colors
        self.position = position
        self.angle = angle ?? .degrees(position.edge.degrees)
    }

    var currentCwColor: CellColor { position.flipped ? side2Colors.cwColor : side1Colors.cwColor }
    var currentAcwColor: CellColor { position.flipped ? side2Colors.acwColor : side1Colors.acwColor }

    var oppositeCwColor: CellColor { position.flipped ? side1Colors.cwColor : side2Colors.cwColor }
    var oppositeAcwColor: CellColor { position.flipped ? side1Colors.acwColor : side2Colors.acwColor }

    static let hold1: Hold = .init(
        id: .one,
        side1Colors: .init(cwColor: .green, acwColor: .red),
        side2Colors: .init(cwColor: .yellow, acwColor: .blue),
        position: .init(edge: .left, flipped: false)
    )
//    static let hold2: Hold = .init(
//        side1Colors: .init(cwColor: .yellow, acwColor: .red),
//        side2Colors: .init(cwColor: .green, acwColor: .blue),
//        position: .init(edge: .right, flipped: false)
//    )
    static let hold2: Hold = .init(
        id: .two,
        side1Colors: .init(cwColor: .red, acwColor: .yellow),
        side2Colors: .init(cwColor: .blue, acwColor: .green),
        position: .init(edge: .right, flipped: false)
    )
}

enum HoldID: String {
    case one
    case two
}

struct HoldSideColors: Equatable {
    var cwColor: CellColor
    var acwColor: CellColor
}

struct HoldPosition: Equatable {
    var edge: EdgePosition
    var flipped: Bool // false = side 1, true = side 2

    /// Which quadrants the CW and ACW colours take up in this position
    /// ```
    ///      ACW CW
    ///  CW   TL TR  ACW
    ///  ACW  BL BR  CW
    ///       CW ACW
    /// ```
    ///
    var quadrants: (acw: Quadrant, cw: Quadrant) {
        switch self.edge {
        case .top: (.topLeft, .topRight)
        case .left: (.bottomLeft, .topLeft)
        case .bottom: (.bottomRight, .bottomLeft)
        case .right: (.topRight, .bottomRight)
        }
    }
}

enum EdgePosition: String, Equatable, CaseIterable {
    case top
    case left
    case bottom
    case right

    /// The next edge position in the clockwise direction
    var cwNext: EdgePosition {
        switch self {
        case .top: .left
        case .left: .bottom
        case .bottom: .right
        case .right: .top
        }
    }
    /// The next edge position in the anticlockwise direction
    var acwNext: EdgePosition {
        switch self {
        case .top: .right
        case .left: .top
        case .bottom: .left
        case .right: .bottom
        }
    }

    /// The angle that this edge represents, in degrees from positive x-axis
    var degrees: CGFloat {
        switch self {
        case .top: 90
        case .left: 180
        case .bottom: 270
        case .right: 0
        }
    }

    /// The edge position closest to the given angle from the positive x-axis, in degrees
    static func closest(toDegrees deg: CGFloat) -> EdgePosition {
        // make deg 0 to 360
        let rationalised = deg.posRemainder(dividingBy: 360)

        if rationalised < 0 + 45 || rationalised >= 360 - 45 {
            return .right
        } else if 90 - 45 <= rationalised && rationalised < 90 + 45 {
            return .top
        } else if 180 - 45 <= rationalised && rationalised < 180 + 45 {
            return .left
        } else {
            return .bottom
        }
    }
}
