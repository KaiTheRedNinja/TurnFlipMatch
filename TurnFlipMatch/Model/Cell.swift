//
//  Cell.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import SwiftUI

enum CellColor: String, CaseIterable, Identifiable, Equatable {
    case red
    case green
    case blue
    case yellow

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .red: Color.red
        case .green: Color.green
        case .blue: Color.blue
        case .yellow: Color.yellow
        }
    }
}

enum Quadrant: Int, CaseIterable, Equatable {
    case topRight = 1
    case topLeft = 2
    case bottomLeft = 3
    case bottomRight = 4
}
