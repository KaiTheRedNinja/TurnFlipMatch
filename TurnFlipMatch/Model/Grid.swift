//
//  Grid.swift
//  TurnFlipMatch
//
//  Created by Kai Quan Tay on 11/11/26.
//

import SwiftUI

struct QuadrantGrid<Cell: Equatable>: Equatable {
    var cells: [Quadrant: Cell]

    init(cells: [Quadrant: Cell]) {
        self.cells = cells
    }

    init(all: Cell?) {
        self.cells = [
            .topLeft: all,
            .topRight: all,
            .bottomLeft: all,
            .bottomRight: all
        ].compactMapValues { $0 }
    }
}

typealias ColorGrid = QuadrantGrid<CellColor>

extension ColorGrid {
    static let empty = ColorGrid(cells: [:])
}

typealias BrightnessGrid = QuadrantGrid<CellBrightness>

extension BrightnessGrid {
    static let allHigh = BrightnessGrid(all: .high)
    static let allOff = BrightnessGrid(all: .off)
}

struct RenderedGrid: Equatable {
    var color: ColorGrid = .empty
    var brightness: BrightnessGrid = .allHigh

    func uiColor(forQuad quadrant: Quadrant) -> Color {
        color.cells[quadrant]?.color ?? .init(white: 0.2)
    }

    // negative = darker, 0 = unchanged, positive = brighter
    func uiBrightness(forQuad quadrant: Quadrant) -> CGFloat {
        // an empty cell has no brightness to change
        guard color.cells[quadrant] != nil else { return 0 }
        // default to off, which is -50% brightness.
        switch brightness.cells[quadrant] {
        case .high: return 0.0
        case .off, nil: return -0.5
        }
    }

    static let empty = RenderedGrid(color: .empty, brightness: .allHigh)
}
